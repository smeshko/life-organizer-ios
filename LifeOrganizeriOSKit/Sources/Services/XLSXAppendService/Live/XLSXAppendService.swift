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

        // Find last row index
        let lastRowIndex = try findLastRowIndex(in: worksheetXML)
        let newRowIndex = lastRowIndex + 1

        // Generate new row XML
        let rowXML = generateRowXML(rowIndex: newRowIndex, values: values)

        // Insert row into worksheet
        let modifiedXML = try appendRowToWorksheet(
            worksheetXML: worksheetXML,
            rowXML: rowXML
        )

        // Write back to file
        try modifiedXML.write(to: worksheetURL, atomically: true, encoding: .utf8)
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
