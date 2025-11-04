import Foundation
import ZIPFoundation
import Framework

/// Live implementation of XLSXAppendService
public struct XLSXAppendService: XLSXAppendServiceProtocol, Sendable {
    public init() {}

    public func appendRow(
        to fileURL: URL,
        sheetName: String,
        values: [String]
    ) async throws -> URL {
        // 1. Validate inputs
        try validateInputs(fileURL: fileURL, sheetName: sheetName, values: values)

        let fileManager = FileManager.default

        // 2. Create temp directory with unique ID
        let tempDir = fileManager.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        // Ensure cleanup happens in all cases
        defer {
            try? fileManager.removeItem(at: tempDir)
        }

        do {
            // 3. Unzip XLSX to temp directory
            try fileManager.unzipItem(at: fileURL, to: tempDir)

            // 4. Find target worksheet
            let worksheetPath = try findTargetWorksheet(
                in: tempDir,
                sheetName: sheetName,
                fileManager: fileManager
            )

            // 5. Modify worksheet XML
            try modifyWorksheet(at: worksheetPath, values: values)

            // 6. Rezip modified files - zip contents individually to avoid nesting
            let outputURL = fileManager.temporaryDirectory
                .appendingPathComponent("\(UUID().uuidString)_output.xlsx")
            try zipDirectoryContents(at: tempDir, to: outputURL, fileManager: fileManager)

            // 7. Return the output URL (it's already outside tempDir, so won't be cleaned up)
            return outputURL

        } catch let error as AppError {
            // Already a domain error - rethrow as-is
            throw error
        } catch {
            // Wrap other errors as XLSX errors
            throw AppError.xlsx(
                .worksheetModificationFailed(error.localizedDescription)
            )
        }
    }

    // MARK: - Private Helpers

    /// Validates input parameters
    /// - Parameters:
    ///   - fileURL: The file URL to validate
    ///   - sheetName: The sheet name to validate
    ///   - values: The values array to validate
    /// - Throws: AppError.xlsx if validation fails
    private func validateInputs(
        fileURL: URL,
        sheetName: String,
        values: [String]
    ) throws {
        let fileManager = FileManager.default

        // Verify file exists and is accessible
        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw AppError.xlsx(.fileNotFound)
        }

        // Verify sheet name is not empty
        guard !sheetName.isEmpty else {
            throw AppError.xlsx(.invalidInputParameters("Sheet name cannot be empty"))
        }

        // Verify values array is not empty
        guard !values.isEmpty else {
            throw AppError.xlsx(.invalidInputParameters("Values array cannot be empty"))
        }
    }

    /// Finds the target worksheet file within the extracted XLSX
    /// - Parameters:
    ///   - extractedDir: Directory containing extracted XLSX contents
    ///   - sheetName: Name of the target worksheet
    ///   - fileManager: FileManager instance to use
    /// - Returns: URL to the worksheet XML file
    /// - Throws: AppError.xlsx if worksheet cannot be found
    private func findTargetWorksheet(
        in extractedDir: URL,
        sheetName: String,
        fileManager: FileManager
    ) throws -> URL {
        // Read workbook.xml
        let workbookURL = extractedDir
            .appendingPathComponent("xl")
            .appendingPathComponent("workbook.xml")
        let workbookXML = try String(contentsOf: workbookURL, encoding: .utf8)

        // Find relationship ID for sheet name
        let relationshipID = try findSheetRelationshipID(
            in: workbookXML,
            sheetName: sheetName
        )

        // Read workbook.xml.rels
        let relsURL = extractedDir
            .appendingPathComponent("xl")
            .appendingPathComponent("_rels")
            .appendingPathComponent("workbook.xml.rels")
        let relsXML = try String(contentsOf: relsURL, encoding: .utf8)

        // Find worksheet path from relationship ID
        let worksheetPath = try findWorksheetPath(
            in: relsXML,
            relationshipID: relationshipID
        )

        // Construct full worksheet URL
        return extractedDir
            .appendingPathComponent("xl")
            .appendingPathComponent(worksheetPath)
    }

    /// Modifies the worksheet XML by appending a new row
    /// - Parameters:
    ///   - worksheetURL: URL to the worksheet XML file
    ///   - values: Array of values for the new row
    /// - Throws: AppError.xlsx if modification fails
    private func modifyWorksheet(
        at worksheetURL: URL,
        values: [String]
    ) throws {
        // Read worksheet XML
        let worksheetXML = try String(contentsOf: worksheetURL, encoding: .utf8)

        // Check if worksheet has tables and get table info
        let tableInfo = try findTableReferences(
            worksheetURL: worksheetURL,
            worksheetXML: worksheetXML
        )

        let insertionResult: (xml: String, rowIndex: Int)
        if let table = tableInfo {
            insertionResult = try insertRowInTable(
                worksheetXML: worksheetXML,
                values: values,
                tableInfo: table
            )
        } else {
            insertionResult = try insertRowInPlainWorksheet(
                worksheetXML: worksheetXML,
                values: values
            )
        }

        // Write back to file
        try insertionResult.xml.write(to: worksheetURL, atomically: true, encoding: .utf8)

        // Update table definition if this worksheet has tables
        if let table = tableInfo {
            try updateTableDefinition(
                tableURL: table.tableURL,
                newLastRow: max(insertionResult.rowIndex, table.endRow),
                currentRef: table.ref
            )
        }
    }

    /// Inserts a row into a worksheet without table metadata
    /// - Parameters:
    ///   - worksheetXML: Original worksheet XML
    ///   - values: Values to insert
    /// - Returns: Tuple with modified XML and the row index used
    private func insertRowInPlainWorksheet(
        worksheetXML: String,
        values: [String]
    ) throws -> (xml: String, rowIndex: Int) {
        let lastRowIndex = try findLastRowIndex(in: worksheetXML)
        let newRowIndex = lastRowIndex + 1
        let rowXML = generateRowXML(rowIndex: newRowIndex, values: values)
        let modifiedXML = try appendRowToWorksheet(
            worksheetXML: worksheetXML,
            rowXML: rowXML
        )
        return (modifiedXML, newRowIndex)
    }

    /// Inserts or updates a row within a table-aware worksheet
    /// - Parameters:
    ///   - worksheetXML: Original worksheet XML
    ///   - values: Values to insert
    ///   - tableInfo: Table metadata
    /// - Returns: Tuple with modified XML and the row index used
    private func insertRowInTable(
        worksheetXML: String,
        values: [String],
        tableInfo: TableInfo
    ) throws -> (xml: String, rowIndex: Int) {
        let rows = try extractWorksheetRows(from: worksheetXML)
        var rowsByIndex: [Int: WorksheetRow] = [:]
        rows.forEach { rowsByIndex[$0.index] = $0 }

        let startColumnIndex = columnIndex(from: tableInfo.startColumn)
        let columnLetters = tableInfo.columns.enumerated().map { index, _ in
            columnLetter(for: startColumnIndex + index)
        }
        let dataColumns = tableInfo.columns.enumerated().compactMap { index, column -> String? in
            guard !column.isCalculated else { return nil }
            return columnLetter(for: startColumnIndex + index)
        }

        let dataStartRow = tableInfo.startRow + 1
        let dataEndRow = tableInfo.endRow

        var lastDataRowIndex = dataStartRow - 1
        var lastDataRow: WorksheetRow?

        for row in rows where row.index >= dataStartRow && row.index <= dataEndRow {
            if rowHasUserData(row.xml, rowIndex: row.index, dataColumns: dataColumns) {
                lastDataRowIndex = row.index
                lastDataRow = row
            }
        }

        let targetRowIndex = max(lastDataRowIndex + 1, dataStartRow)
        let existingRow = rowsByIndex[targetRowIndex]
        let templateRow = lastDataRow ?? existingRow

        let rowXML = try buildTableRowXML(
            rowIndex: targetRowIndex,
            values: values,
            tableInfo: tableInfo,
            columnLetters: columnLetters,
            dataColumns: dataColumns,
            existingRow: existingRow,
            templateRow: templateRow
        )

        if let existingRow = existingRow {
            let replacement = replaceRow(
                in: worksheetXML,
                row: existingRow,
                with: rowXML
            )
            return (replacement, targetRowIndex)
        } else {
            let modifiedXML = try appendRowToWorksheet(
                worksheetXML: worksheetXML,
                rowXML: rowXML
            )
            return (modifiedXML, targetRowIndex)
        }
    }

    // MARK: - Table Handling

    /// Information about an Excel Table
    private struct TableInfo {
        let tableURL: URL
        let ref: String // e.g., "C11:I1334"
        let columns: [TableColumn]
        let startColumn: String // e.g., "C"
        let startRow: Int // e.g., 11 (header row)
        let endColumn: String // e.g., "I"
        let endRow: Int // e.g., 1334
    }

    /// Information about a table column
    private struct TableColumn {
        let name: String
        let isCalculated: Bool
        let formula: String? // The calculated formula if isCalculated is true
    }

    /// Represents a worksheet row match within the XML
    private struct WorksheetRow {
        let index: Int
        let range: Range<String.Index>
        let xml: String
    }

    /// Captures information about a single cell
    private struct CellContext {
        var attributes: [String: String]
        var innerXML: String?
        var rowIndex: Int?
    }

    /// Finds table references for the given worksheet
    /// - Parameters:
    ///   - worksheetURL: URL to the worksheet file
    ///   - worksheetXML: The worksheet XML content
    /// - Returns: TableInfo if worksheet contains a table, nil otherwise
    private func findTableReferences(
        worksheetURL: URL,
        worksheetXML: String
    ) throws -> TableInfo? {
        // Check for tableParts in worksheet XML
        guard worksheetXML.contains("<tableParts") || worksheetXML.contains("<tablePart") else {
            return nil // No tables in this worksheet
        }

        // Find worksheet relationships file
        let worksheetDir = worksheetURL.deletingLastPathComponent()
        let worksheetName = worksheetURL.deletingPathExtension().lastPathComponent
        let relsURL = worksheetDir
            .appendingPathComponent("_rels")
            .appendingPathComponent("\(worksheetName).xml.rels")

        // Check if rels file exists
        guard FileManager.default.fileExists(atPath: relsURL.path) else {
            return nil
        }

        let relsXML = try String(contentsOf: relsURL, encoding: .utf8)

        // Find table relationship
        let tablePattern = #"<Relationship[^>]*Type="[^"]*table"[^>]*Target="([^"]+)""#
        let tableRegex = try NSRegularExpression(pattern: tablePattern)
        let tableMatches = tableRegex.matches(
            in: relsXML,
            range: NSRange(relsXML.startIndex..., in: relsXML)
        )

        guard let firstMatch = tableMatches.first,
              let range = Range(firstMatch.range(at: 1), in: relsXML) else {
            return nil
        }

        let tablePath = String(relsXML[range])
        let tableURL = worksheetDir.appendingPathComponent(tablePath)

        // Read table definition
        let tableXML = try String(contentsOf: tableURL, encoding: .utf8)

        // Extract table ref (e.g., ref="C11:I1334")
        guard let refMatch = try NSRegularExpression(pattern: #"<table[^>]*ref="([^"]+)""#)
            .firstMatch(in: tableXML, range: NSRange(tableXML.startIndex..., in: tableXML)),
              let refRange = Range(refMatch.range(at: 1), in: tableXML) else {
            throw AppError.xlsx(.xmlParsingFailed("Could not find table ref"))
        }

        let ref = String(tableXML[refRange])

        // Parse ref to get start column and row (e.g., "C11:I1334" -> startColumn="C", startRow=11)
        let refComponents = ref.split(separator: ":")
        guard refComponents.count == 2 else {
            throw AppError.xlsx(.xmlParsingFailed("Invalid table ref format"))
        }

        let startCell = String(refComponents[0])
        let startColumn = String(startCell.prefix(while: { $0.isLetter }))
        let startRow = Int(startCell.dropFirst(startColumn.count)) ?? 0

        let endCell = String(refComponents[1])
        let endColumn = String(endCell.prefix(while: { $0.isLetter }))
        let endRow = Int(endCell.dropFirst(endColumn.count)) ?? startRow

        // Extract columns info
        let columns = try parseTableColumns(from: tableXML)

        return TableInfo(
            tableURL: tableURL,
            ref: ref,
            columns: columns,
            startColumn: startColumn,
            startRow: startRow,
            endColumn: endColumn,
            endRow: endRow
        )
    }

    /// Parses table column definitions from table XML
    private func parseTableColumns(from tableXML: String) throws -> [TableColumn] {
        var columns: [TableColumn] = []

        // Split approach: find each <tableColumn...> or <tableColumn.../> tag
        // Match the full tag including the closing
        // Important: Use \s to ensure we don't match <tableColumns> (with 's')
        let pattern = #"<tableColumn\s[^/>]+(/>|>)"#
        let regex = try NSRegularExpression(pattern: pattern)
        let matches = regex.matches(
            in: tableXML,
            range: NSRange(tableXML.startIndex..., in: tableXML)
        )

        for match in matches {
            guard let tagRange = Range(match.range, in: tableXML),
                  let closingRange = Range(match.range(at: 1), in: tableXML) else {
                continue
            }

            let tag = String(tableXML[tagRange])
            let closing = String(tableXML[closingRange])

            // Extract name attribute from the tag
            guard let nameMatch = try NSRegularExpression(pattern: #"name="([^"]+)""#)
                .firstMatch(in: tag, range: NSRange(tag.startIndex..., in: tag)),
                  let nameRange = Range(nameMatch.range(at: 1), in: tag) else {
                continue
            }

            let name = String(tag[nameRange])

            // Check if this column has calculated formula
            let isCalculated: Bool
            if closing == "/>" {
                // Self-closing tag - not calculated
                isCalculated = false
            } else {
                // Has content - search for calculatedColumnFormula after this tag
                let searchStart = match.range.upperBound
                let remainingXML = String(tableXML[tableXML.index(tableXML.startIndex, offsetBy: searchStart)...])

                if let endTag = remainingXML.range(of: "</tableColumn>") {
                    let columnContent = String(remainingXML[..<endTag.lowerBound])
                    // Search for calculatedColumnFormula (without <, since we're already past the opening tag)
                    isCalculated = columnContent.contains("calculatedColumnFormula")
                } else {
                    isCalculated = false
                }
            }

            // Extract formula if needed (for now we'll just mark it as calculated)
            // Excel will recalculate these automatically
            let formula: String? = nil

            columns.append(TableColumn(name: name, isCalculated: isCalculated, formula: formula))
        }

        return columns
    }

    /// Converts column letter to zero-based index (inverse of columnLetter)
    private func columnIndex(from letter: String) -> Int {
        var index = 0
        for char in letter.uppercased() {
            guard let ascii = char.asciiValue, ascii >= 65, ascii <= 90 else {
                continue
            }
            index = index * 26 + Int(ascii - 64)
        }
        return index - 1
    }

    /// Updates the table definition to extend the range
    private func updateTableDefinition(
        tableURL: URL,
        newLastRow: Int,
        currentRef: String
    ) throws {
        // Read table XML
        var tableXML = try String(contentsOf: tableURL, encoding: .utf8)

        // Parse current ref to get start and end
        let refComponents = currentRef.split(separator: ":")
        guard refComponents.count == 2 else {
            throw AppError.xlsx(.xmlParsingFailed("Invalid table ref format"))
        }

        let startCell = String(refComponents[0])
        let endCell = String(refComponents[1])

        // Extract end column from end cell (e.g., "I1334" -> "I")
        let endColumn = String(endCell.prefix(while: { $0.isLetter }))

        // Create new ref with updated last row
        let newRef = "\(startCell):\(endColumn)\(newLastRow)"

        // Update all occurrences of the ref in table XML
        // Update main table ref attribute
        tableXML = tableXML.replacingOccurrences(
            of: #"ref="\#(currentRef)""#,
            with: #"ref="\#(newRef)""#
        )

        // Update autoFilter ref if present
        tableXML = tableXML.replacingOccurrences(
            of: #"<autoFilter ref="\#(currentRef)""#,
            with: #"<autoFilter ref="\#(newRef)""#
        )

        // Update sortState ref if present (needs to adjust data range, excluding header)
        let startRow = Int(startCell.dropFirst(startCell.prefix(while: { $0.isLetter }).count)) ?? 0
        let dataStartRow = startRow + 1 // First row after header
        let dataSortRef = "\(startCell.prefix(while: { $0.isLetter }))\(dataStartRow):\(endColumn)\(newLastRow)"

        // Match sortState with the old ref pattern
        let oldDataRef = "\(startCell.prefix(while: { $0.isLetter }))\(dataStartRow):\(endCell)"
        tableXML = tableXML.replacingOccurrences(
            of: #"<sortState ref="\#(oldDataRef)""#,
            with: #"<sortState ref="\#(dataSortRef)""#
        )

        // Write back to file
        try tableXML.write(to: tableURL, atomically: true, encoding: .utf8)
    }
}

// MARK: - Row & Cell Helpers

private extension XLSXAppendService {
    private func extractWorksheetRows(from worksheetXML: String) throws -> [WorksheetRow] {
        let pattern = #"<row[^>]*r="(\d+)"[^>]*>.*?</row>"#
        let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let nsRange = NSRange(worksheetXML.startIndex..., in: worksheetXML)

        return regex.matches(in: worksheetXML, range: nsRange).compactMap { match in
            guard
                let rowRange = Range(match.range, in: worksheetXML),
                let indexRange = Range(match.range(at: 1), in: worksheetXML),
                let rowIndex = Int(worksheetXML[indexRange])
            else { return nil }

            let rowXML = String(worksheetXML[rowRange])
            return WorksheetRow(index: rowIndex, range: rowRange, xml: rowXML)
        }
    }

    private func rowHasUserData(_ rowXML: String, rowIndex: Int, dataColumns: [String]) -> Bool {
        let trimmedColumns = dataColumns
        for column in trimmedColumns {
            if let cell = extractCellContext(from: rowXML, column: column, rowIndex: rowIndex) {
                if let inner = cell.innerXML {
                    if inner.contains("<v>") {
                        return true
                    }
                    if let textRange = inner.range(of: "<t>") {
                        let closingRange = inner.range(of: "</t>", range: textRange.upperBound..<inner.endIndex)
                        if let closingRange = closingRange {
                            let value = inner[textRange.upperBound..<closingRange.lowerBound]
                            if !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }

    private func buildTableRowXML(
        rowIndex: Int,
        values: [String],
        tableInfo: TableInfo,
        columnLetters: [String],
        dataColumns: [String],
        existingRow: WorksheetRow?,
        templateRow: WorksheetRow?
    ) throws -> String {
        let dataColumnCount = tableInfo.columns.filter { !$0.isCalculated }.count
        guard values.count <= dataColumnCount else {
            throw AppError.xlsx(
                .invalidInputParameters(
                    "Received \(values.count) values but table supports only \(dataColumnCount) data columns"
                )
            )
        }

        var rowAttributes: [String: String] = [:]
        if let existingRow = existingRow {
            rowAttributes = parseRowAttributes(from: existingRow.xml)
        } else if let templateRow = templateRow {
            rowAttributes = parseRowAttributes(from: templateRow.xml)
        }

        if rowAttributes.isEmpty {
            rowAttributes["spans"] = spanRangeString(
                startColumn: tableInfo.startColumn,
                columnCount: tableInfo.columns.count
            )
        }
        rowAttributes["r"] = "\(rowIndex)"

        var cellStrings: [String] = []
        var valueCursor = 0

        for (offset, tableColumn) in tableInfo.columns.enumerated() {
            let columnLetter = columnLetters[offset]
            let existingContext = existingRow.flatMap {
                extractCellContext(from: $0.xml, column: columnLetter, rowIndex: rowIndex)
            }
            let templateContext = templateRow.flatMap {
                extractCellContext(from: $0.xml, column: columnLetter, rowIndex: $0.index)
            }

            if tableColumn.isCalculated {
                let cellString = buildCalculatedCell(
                    column: columnLetter,
                    rowIndex: rowIndex,
                    baseContext: existingContext,
                    fallbackContext: templateContext
                )
                cellStrings.append(cellString)
            } else {
                let value = valueCursor < values.count ? values[valueCursor] : ""
                valueCursor += 1

                let baseAttributes = existingContext?.attributes ?? templateContext?.attributes ?? [:]
                let cellString = buildDataCell(
                    tableColumn: tableColumn,
                    baseAttributes: baseAttributes,
                    column: columnLetter,
                    rowIndex: rowIndex,
                    value: value
                )
                cellStrings.append(cellString)
            }
        }

        var rowXML = "    " + startTag(name: "row", attributes: rowAttributes) + "\n"
        if !cellStrings.isEmpty {
            rowXML += cellStrings.joined(separator: "\n") + "\n"
        }
        rowXML += "    </row>"
        return rowXML
    }

    private func buildDataCell(
        tableColumn: TableColumn,
        baseAttributes: [String: String],
        column: String,
        rowIndex: Int,
        value: String
    ) -> String {
        var attributes = baseAttributes
        attributes["r"] = "\(column)\(rowIndex)"

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.isEmpty {
            attributes.removeValue(forKey: "t")
            return "      " + element(name: "c", attributes: attributes, innerXML: nil)
        }

        if let serialValue = excelSerialValue(for: trimmedValue, column: tableColumn) {
            attributes.removeValue(forKey: "t")
            let innerXML = "<v>\(serialValue)</v>"
            return "      " + element(name: "c", attributes: attributes, innerXML: innerXML)
        }

        if Double(trimmedValue) != nil {
            attributes.removeValue(forKey: "t")
            let innerXML = "<v>\(trimmedValue)</v>"
            return "      " + element(name: "c", attributes: attributes, innerXML: innerXML)
        } else {
            attributes["t"] = "inlineStr"
            let escaped = xmlEscape(trimmedValue)
            let innerXML = "<is><t>\(escaped)</t></is>"
            return "      " + element(name: "c", attributes: attributes, innerXML: innerXML)
        }
    }

    private func buildCalculatedCell(
        column: String,
        rowIndex: Int,
        baseContext: CellContext?,
        fallbackContext: CellContext?
    ) -> String {
        let context = baseContext ?? fallbackContext
        var attributes = context?.attributes ?? [:]
        attributes["r"] = "\(column)\(rowIndex)"

        var innerXML = context?.innerXML
        if
            let originalRowIndex = context?.rowIndex,
            originalRowIndex != rowIndex,
            let existingInner = innerXML
        {
            innerXML = existingInner.replacingOccurrences(of: "\(column)\(originalRowIndex)", with: "\(column)\(rowIndex)")
        }

        if let inner = innerXML {
            innerXML = removeCachedValue(from: inner)
        }

        return "      " + element(name: "c", attributes: attributes, innerXML: innerXML)
    }

    private func replaceRow(
        in worksheetXML: String,
        row: WorksheetRow,
        with newRowXML: String
    ) -> String {
        let prefix = worksheetXML[..<row.range.lowerBound]
        let suffix = worksheetXML[row.range.upperBound...]
        return String(prefix) + newRowXML + String(suffix)
    }

    private func parseRowAttributes(from rowXML: String) -> [String: String] {
        guard let attributeString = extractAttributeString(from: rowXML, tagName: "row") else {
            return [:]
        }
        return parseAttributes(from: attributeString)
    }

    private func startTag(name: String, attributes: [String: String]) -> String {
        let elements = attributes.sorted { $0.key < $1.key }.map { "\($0.key)=\"\($0.value)\"" }
        if elements.isEmpty {
            return "<\(name)>"
        } else {
            return "<\(name) \(elements.joined(separator: " "))>"
        }
    }

    private func element(
        name: String,
        attributes: [String: String],
        innerXML: String?
    ) -> String {
        let elements = attributes.sorted { $0.key < $1.key }.map { "\($0.key)=\"\($0.value)\"" }
        let attributeSegment = elements.joined(separator: " ")
        let spacing = attributeSegment.isEmpty ? "" : " "

        if let innerXML = innerXML {
            return "<\(name)\(spacing)\(attributeSegment)>\(innerXML)</\(name)>"
        } else {
            return "<\(name)\(spacing)\(attributeSegment)/>"
        }
    }

    private func extractCellContext(
        from rowXML: String,
        column: String,
        rowIndex: Int
    ) -> CellContext? {
        let pattern = #"<c[^>]*r="\#(column)\#(rowIndex)"[^>]*/>|<c[^>]*r="\#(column)\#(rowIndex)"[^>]*>.*?</c>"#
        guard
            let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
            let match = regex.firstMatch(
                in: rowXML,
                range: NSRange(rowXML.startIndex..., in: rowXML)
            ),
            let range = Range(match.range, in: rowXML)
        else {
            return nil
        }

        let cellXML = String(rowXML[range])
        guard let attributeString = extractAttributeString(from: cellXML, tagName: "c") else {
            return CellContext(attributes: [:], innerXML: nil, rowIndex: nil)
        }

        let attributes = parseAttributes(from: attributeString)

        var innerXML: String?
        if cellXML.contains("</c>"), let start = cellXML.firstIndex(of: ">"),
           let closingRange = cellXML.range(of: "</c>", options: .backwards) {
            let innerStart = cellXML.index(after: start)
            innerXML = String(cellXML[innerStart..<closingRange.lowerBound])
        }

        let originalReference = attributes["r"]
        let originalRowIndex = originalReference.flatMap { parseRowIndex(from: $0, column: column) }
        return CellContext(attributes: attributes, innerXML: innerXML, rowIndex: originalRowIndex)
    }

    private func extractAttributeString(from element: String, tagName: String) -> String? {
        let trimmed = element.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix("<\(tagName)") else { return nil }
        guard let endIndex = trimmed.firstIndex(of: ">") else { return nil }

        var attributeSubstring = trimmed[trimmed.index(trimmed.startIndex, offsetBy: tagName.count + 1)..<endIndex]
        if attributeSubstring.hasSuffix("/") {
            attributeSubstring = attributeSubstring.dropLast()
        }
        return String(attributeSubstring).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseAttributes(from attributeString: String) -> [String: String] {
        var result: [String: String] = [:]
        let regex = try? NSRegularExpression(pattern: #"([A-Za-z0-9:_-]+)="([^"]*)""#)
        let nsRange = NSRange(attributeString.startIndex..., in: attributeString)
        regex?.enumerateMatches(in: attributeString, range: nsRange) { match, _, _ in
            guard
                let match = match,
                let keyRange = Range(match.range(at: 1), in: attributeString),
                let valueRange = Range(match.range(at: 2), in: attributeString)
            else { return }
            let key = String(attributeString[keyRange])
            let value = String(attributeString[valueRange])
            result[key] = value
        }
        return result
    }

    private func parseRowIndex(from reference: String, column: String) -> Int? {
        let digits = reference.filter { $0.isNumber }
        return Int(digits)
    }

    private func spanRangeString(startColumn: String, columnCount: Int) -> String {
        let start = columnIndex(from: startColumn) + 1
        let end = start + columnCount - 1
        return "\(start):\(end)"
    }

    private static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static let excelBaseDate: Date = {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = 1899
        components.month = 12
        components.day = 30
        guard let date = components.date else {
            return Date(timeIntervalSince1970: 0)
        }
        return date
    }()

    private func excelSerialValue(for value: String, column: TableColumn) -> String? {
        guard column.name.lowercased() == "date" else { return nil }
        guard let date = Self.isoDateFormatter.date(from: value) else { return nil }

        let days = Self.utcCalendar.dateComponents(
            [.day],
            from: Self.excelBaseDate,
            to: date
        ).day ?? 0

        return String(days)
    }

    private func removeCachedValue(from innerXML: String) -> String {
        innerXML.replacingOccurrences(
            of: #"<v>.*?</v>"#,
            with: "",
            options: .regularExpression
        )
    }
}

// MARK: - XML Utility Functions
private extension XLSXAppendService {
    /// Escapes special XML characters in a string
    /// - Parameter string: The string to escape
    /// - Returns: XML-safe string with special characters escaped
    func xmlEscape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    /// Converts a zero-based column index to Excel letter notation
    /// - Parameter index: Zero-based column index (0 = A, 1 = B, 25 = Z, 26 = AA)
    /// - Returns: Excel column letter(s) (e.g., "A", "Z", "AA", "AB")
    func columnLetter(for index: Int) -> String {
        var column = index
        var result = ""

        while column >= 0 {
            result = String(UnicodeScalar(65 + (column % 26))!) + result
            column = column / 26 - 1
            if column < 0 { break }
        }

        return result
    }

    /// Finds the last row index in worksheet XML
    /// - Parameter xml: The worksheet XML string
    /// - Returns: The last row number, or 0 if no rows exist
    /// - Throws: AppError.xlsx if regex pattern fails
    func findLastRowIndex(in xml: String) throws -> Int {
        let pattern = #"<row r="(\d+)""#
        let regex = try NSRegularExpression(pattern: pattern)
        let matches = regex.matches(
            in: xml,
            range: NSRange(xml.startIndex..., in: xml)
        )

        guard let lastMatch = matches.last,
              let range = Range(lastMatch.range(at: 1), in: xml) else {
            return 0 // No rows yet
        }

        return Int(xml[range]) ?? 0
    }

    /// Generates XML for a single cell
    /// - Parameters:
    ///   - column: Excel column letter (e.g., "A", "B", "AA")
    ///   - row: Row number (1-indexed)
    ///   - value: Cell value as string
    /// - Returns: XML string for the cell element
    func generateCellXML(column: String, row: Int, value: String) -> String {
        let cellRef = "\(column)\(row)"
        let escapedValue = xmlEscape(value)

        // Try to parse as number
        if let _ = Double(value) {
            // Numeric cell: <c r="A1"><v>123.45</v></c>
            return #"<c r="\#(cellRef)"><v>\#(escapedValue)</v></c>"#
        } else {
            // Text cell: <c r="A1" t="inlineStr"><is><t>Text</t></is></c>
            return #"<c r="\#(cellRef)" t="inlineStr"><is><t>\#(escapedValue)</t></is></c>"#
        }
    }

    /// Generates XML for a complete row
    /// - Parameters:
    ///   - rowIndex: Row number (1-indexed)
    ///   - values: Array of cell values
    /// - Returns: XML string for the row element with all cells
    func generateRowXML(rowIndex: Int, values: [String]) -> String {
        // Use proper indentation to match Excel's XML format
        var rowXML = #"    <row r="\#(rowIndex)">"# + "\n"

        for (columnIndex, value) in values.enumerated() {
            let column = columnLetter(for: columnIndex)
            rowXML += "      " + generateCellXML(column: column, row: rowIndex, value: value) + "\n"
        }

        rowXML += "    </row>"
        return rowXML
    }

    /// Finds the relationship ID for a sheet by name in workbook.xml
    /// - Parameters:
    ///   - workbookXML: The xl/workbook.xml content
    ///   - sheetName: The target sheet name
    /// - Returns: The relationship ID (e.g., "rId1")
    /// - Throws: AppError.xlsx(.sheetNotFound) if sheet doesn't exist
    func findSheetRelationshipID(
        in workbookXML: String,
        sheetName: String
    ) throws -> String {
        // Escape sheet name for safe regex usage
        let escapedName = NSRegularExpression.escapedPattern(for: sheetName)
        let pattern = #"<sheet name="\#(escapedName)"[^>]*r:id="([^"]+)""#

        let regex = try NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(workbookXML.startIndex..., in: workbookXML)

        guard let match = regex.firstMatch(in: workbookXML, range: nsRange),
              let range = Range(match.range(at: 1), in: workbookXML) else {
            throw AppError.xlsx(.sheetNotFound(sheetName))
        }

        return String(workbookXML[range])
    }

    /// Finds the worksheet file path from a relationship ID
    /// - Parameters:
    ///   - relationshipsXML: The xl/_rels/workbook.xml.rels content
    ///   - relationshipID: The relationship ID (e.g., "rId1")
    /// - Returns: Worksheet path relative to xl/ (e.g., "worksheets/sheet1.xml")
    /// - Throws: AppError.xlsx(.xmlParsingFailed) if relationship not found
    func findWorksheetPath(
        in relationshipsXML: String,
        relationshipID: String
    ) throws -> String {
        let escapedID = NSRegularExpression.escapedPattern(for: relationshipID)
        let pattern = #"<Relationship Id="\#(escapedID)"[^>]*Target="([^"]+)""#

        let regex = try NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(relationshipsXML.startIndex..., in: relationshipsXML)

        guard let match = regex.firstMatch(in: relationshipsXML, range: nsRange),
              let range = Range(match.range(at: 1), in: relationshipsXML) else {
            throw AppError.xlsx(
                .xmlParsingFailed("Could not find worksheet path for relationship \(relationshipID)")
            )
        }

        return String(relationshipsXML[range])
    }

    /// Appends a row XML element to worksheet XML
    /// - Parameters:
    ///   - worksheetXML: The original worksheet XML content
    ///   - rowXML: The row XML to append (generated by generateRowXML)
    /// - Returns: Modified worksheet XML with new row inserted
    /// - Throws: AppError.xlsx(.worksheetModificationFailed) if sheetData not found
    func appendRowToWorksheet(
        worksheetXML: String,
        rowXML: String
    ) throws -> String {
        // Validate worksheet structure
        guard worksheetXML.contains("</sheetData>") else {
            throw AppError.xlsx(
                .worksheetModificationFailed(
                    "Invalid worksheet structure - no sheetData element found"
                )
            )
        }

        // Insert row before closing sheetData tag with proper formatting
        // Add newline and indentation to match Excel's format
        let modifiedXML = worksheetXML.replacingOccurrences(
            of: "</sheetData>",
            with: "\(rowXML)\n  </sheetData>"
        )

        return modifiedXML
    }

    /// Zips the contents of a directory without nesting them in a subdirectory
    /// - Parameters:
    ///   - sourceDir: Directory containing files to zip
    ///   - destinationURL: Output ZIP file URL
    ///   - fileManager: FileManager instance
    /// - Throws: AppError if zipping fails
    private func zipDirectoryContents(
        at sourceDir: URL,
        to destinationURL: URL,
        fileManager: FileManager
    ) throws {
        // Create the archive
        let archive = try Archive(url: destinationURL, accessMode: .create)

        // Get all contents of the directory (including .rels files which start with .)
        let contents = try fileManager.contentsOfDirectory(
            at: sourceDir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [] // Don't skip hidden files - .rels files are required!
        )

        // Add each item (file or directory) to the archive
        for itemURL in contents {
            let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
            let itemName = itemURL.lastPathComponent

            if resourceValues.isDirectory == true {
                // Add directory recursively
                try archive.addEntry(
                    with: itemName + "/",
                    relativeTo: sourceDir,
                    compressionMethod: .none
                )
                // Add contents of directory
                try addDirectoryContents(itemURL, to: archive, basePath: itemName, relativeTo: sourceDir)
            } else {
                // Add file
                try archive.addEntry(
                    with: itemName,
                    relativeTo: sourceDir,
                    compressionMethod: .deflate
                )
            }
        }
    }

    /// Helper to recursively add directory contents to an archive
    private func addDirectoryContents(
        _ directory: URL,
        to archive: Archive,
        basePath: String,
        relativeTo sourceDir: URL
    ) throws {
        let contents = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [] // Don't skip hidden files - .rels files are required!
        )

        for itemURL in contents {
            let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
            let itemName = itemURL.lastPathComponent
            let itemPath = basePath + "/" + itemName

            if resourceValues.isDirectory == true {
                try archive.addEntry(
                    with: itemPath + "/",
                    relativeTo: sourceDir,
                    compressionMethod: .none
                )
                try addDirectoryContents(itemURL, to: archive, basePath: itemPath, relativeTo: sourceDir)
            } else {
                try archive.addEntry(
                    with: itemPath,
                    relativeTo: sourceDir,
                    compressionMethod: .deflate
                )
            }
        }
    }
}
