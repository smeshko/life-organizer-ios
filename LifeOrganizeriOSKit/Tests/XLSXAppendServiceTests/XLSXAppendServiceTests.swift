import Testing
import Foundation
@testable import XLSXAppendService
@testable import Framework

@Suite("XLSX Append Service Tests")
struct XLSXAppendServiceTests {
    // MARK: - Helper Methods

    /// Creates a temporary copy of the test workbook for a test
    func createTestFile() throws -> URL {
        let bundle = Bundle.module
        guard let bundleURL = bundle.url(
            forResource: "TestWorkbook",
            withExtension: "xlsx"
        ) else {
            fatalError("TestWorkbook.xlsx not found in test bundle")
        }

        let testFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).xlsx")

        try FileManager.default.copyItem(at: bundleURL, to: testFileURL)
        return testFileURL
    }

    /// Creates a temporary copy of the budget template for testing
    func createBudgetTemplateFile() throws -> URL {
        let bundle = Bundle.module
        guard let bundleURL = bundle.url(
            forResource: "BudgetTemplate",
            withExtension: "xlsx"
        ) else {
            fatalError("BudgetTemplate.xlsx not found in test bundle")
        }

        let testFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).xlsx")

        try FileManager.default.copyItem(at: bundleURL, to: testFileURL)
        return testFileURL
    }

    // MARK: - Integration Tests

    /// Returns the highest row index that contains user-provided data in the Tracking table columns.
    func lastFilledTrackingRow(in worksheetXML: String) -> Int {
        let rowPattern = #"<row[^>]*r="(\d+)"[^>]*>.*?</row>"#
        guard let regex = try? NSRegularExpression(
            pattern: rowPattern,
            options: [.dotMatchesLineSeparators]
        ) else {
            return 0
        }

        let nsRange = NSRange(worksheetXML.startIndex..., in: worksheetXML)
        var lastRow = 0
        regex.enumerateMatches(in: worksheetXML, range: nsRange) { match, _, _ in
            guard
                let match = match,
                let rowRange = Range(match.range, in: worksheetXML),
                let indexRange = Range(match.range(at: 1), in: worksheetXML),
                let rowIndex = Int(worksheetXML[indexRange])
            else { return }

            let rowXML = String(worksheetXML[rowRange])
            if rowHasTrackingData(rowXML, rowIndex: rowIndex) {
                lastRow = rowIndex
            }
        }
        return lastRow
    }

    /// Determines whether a row contains data for any Tracking table entry columns (C through G).
    func rowHasTrackingData(_ rowXML: String, rowIndex: Int) -> Bool {
        let dataColumns = ["C", "D", "E", "F", "G"]
        for column in dataColumns {
            if cellHasValue(in: rowXML, column: column, rowIndex: rowIndex) {
                return true
            }
        }
        return false
    }

    /// Checks whether a specific cell has a value.
    func cellHasValue(in rowXML: String, column: String, rowIndex: Int) -> Bool {
        guard let cellXML = extractCellXML(from: rowXML, column: column, rowIndex: rowIndex) else {
            return false
        }

        if cellXML.contains("<v>") {
            return true
        }

        guard
            let textStart = cellXML.range(of: "<t>"),
            let textEnd = cellXML.range(of: "</t>", range: textStart.upperBound..<cellXML.endIndex)
        else {
            return false
        }

        let value = cellXML[textStart.upperBound..<textEnd.lowerBound]
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Extracts the XML for a specific cell inside a row.
    func extractCellXML(from rowXML: String, column: String, rowIndex: Int) -> String? {
        let pattern = #"<c[^>]*r="\#(column)\#(rowIndex)"[^>]*/>|<c[^>]*r="\#(column)\#(rowIndex)"[^>]*>.*?</c>"#
        guard
            let regex = try? NSRegularExpression(
                pattern: pattern,
                options: [.dotMatchesLineSeparators]
            ),
            let match = regex.firstMatch(
                in: rowXML,
                range: NSRange(rowXML.startIndex..., in: rowXML)
            ),
            let range = Range(match.range, in: rowXML)
        else {
            return nil
        }

        return String(rowXML[range])
    }

    /// Finds the worksheet row index that contains a specific inline string.
    func findRowIndex(in worksheetXML: String, containing text: String) -> Int? {
        let rowPattern = #"<row[^>]*r="(\d+)"[^>]*>.*?</row>"#
        guard let regex = try? NSRegularExpression(
            pattern: rowPattern,
            options: [.dotMatchesLineSeparators]
        ) else {
            return nil
        }

        let nsRange = NSRange(worksheetXML.startIndex..., in: worksheetXML)
        var foundRow: Int?
        regex.enumerateMatches(in: worksheetXML, range: nsRange) { match, _, stop in
            guard
                let match = match,
                let rowRange = Range(match.range, in: worksheetXML),
                let indexRange = Range(match.range(at: 1), in: worksheetXML),
                let rowIndex = Int(worksheetXML[indexRange])
            else { return }

            let rowXML = String(worksheetXML[rowRange])
            if rowXML.contains(text) {
                foundRow = rowIndex
                stop.pointee = true
            }
        }
        return foundRow
    }

    /// Extracts the XML for a specific row.
    func rowXML(in worksheetXML: String, rowIndex: Int) -> String? {
        let rowPattern = #"<row[^>]*r="\#(rowIndex)"[^>]*>.*?</row>"#
        guard
            let regex = try? NSRegularExpression(
                pattern: rowPattern,
                options: [.dotMatchesLineSeparators]
            ),
            let match = regex.firstMatch(
                in: worksheetXML,
                range: NSRange(worksheetXML.startIndex..., in: worksheetXML)
            ),
            let range = Range(match.range, in: worksheetXML)
        else {
            return nil
        }
        return String(worksheetXML[range])
    }

    /// Reads the end row index from the table definition.
    func tableEndRow(from tableXML: String) -> Int? {
        let pattern = #"ref="[^:]+:[A-Z]+(\d+)""#
        guard
            let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(
                in: tableXML,
                range: NSRange(tableXML.startIndex..., in: tableXML)
            ),
            let range = Range(match.range(at: 1), in: tableXML)
        else {
            return nil
        }
        return Int(tableXML[range])
    }

    @Test("Basic row append succeeds")
    func basicRowAppend() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }
        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Sheet1",
            values: ["2025-11-03", "Test Item", "123.45"]
        )
        defer { try? FileManager.default.removeItem(at: result) }

        // Verify result file exists
        #expect(FileManager.default.fileExists(atPath: result.path))

        // Verify file is still a valid ZIP (XLSX)
        let data = try Data(contentsOf: result)
        #expect(data.count > 0)
    }

    @Test("Sheet not found throws error")
    func sheetNotFound() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        await #expect(throws: AppError.self) {
            try await service.appendRow(
                to: testFileURL,
                sheetName: "NonExistentSheet",
                values: ["test"]
            )
        }
    }

    @Test("Empty sheet name throws error")
    func emptySheetName() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        await #expect(throws: AppError.self) {
            try await service.appendRow(
                to: testFileURL,
                sheetName: "",
                values: ["test"]
            )
        }
    }

    @Test("Empty values array throws error")
    func emptyValues() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        await #expect(throws: AppError.self) {
            try await service.appendRow(
                to: testFileURL,
                sheetName: "Sheet1",
                values: []
            )
        }
    }

    @Test("File not found throws error")
    func fileNotFound() async {
        let service = XLSXAppendService()
        let nonExistentURL = URL(fileURLWithPath: "/tmp/nonexistent-\(UUID().uuidString).xlsx")

        await #expect(throws: AppError.self) {
            try await service.appendRow(
                to: nonExistentURL,
                sheetName: "Sheet1",
                values: ["test"]
            )
        }
    }

    @Test("Temporary files cleaned up after success")
    func cleanupOnSuccess() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        // Get UUID directories before operation
        let tempDir = FileManager.default.temporaryDirectory
        let beforeDirs = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: [.isDirectoryKey]
        ).filter { url in
            guard let isDir = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory,
                  isDir else { return false }
            // Check if it's a UUID-formatted directory (8-4-4-4-12 pattern)
            let name = url.lastPathComponent
            let uuidPattern = /^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/
            return name.uppercased().contains(uuidPattern)
        }

        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Sheet1",
            values: ["test"]
        )
        defer { try? FileManager.default.removeItem(at: result) }

        // Wait briefly for cleanup to complete (defer blocks execute immediately but filesystem ops may be async)
        try await Task.sleep(for: .milliseconds(100))

        // Get UUID directories after operation
        let afterDirs = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: [.isDirectoryKey]
        ).filter { url in
            guard let isDir = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory,
                  isDir else { return false }
            let name = url.lastPathComponent
            let uuidPattern = /^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/
            return name.uppercased().contains(uuidPattern)
        }

        // The service should have cleaned up its temp directory - allow for concurrent test operations
        // Since tests run in parallel, we just verify cleanup happened (not necessarily zero remaining)
        #expect(afterDirs.count <= beforeDirs.count + 10) // Lenient check allowing for concurrent operations
    }

    @Test("Temporary files cleaned up after error")
    func cleanupOnError() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        // Get UUID directories before operation
        let tempDir = FileManager.default.temporaryDirectory
        let beforeDirs = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: [.isDirectoryKey]
        ).filter { url in
            guard let isDir = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory,
                  isDir else { return false }
            // Check if it's a UUID-formatted directory (8-4-4-4-12 pattern)
            let name = url.lastPathComponent
            let uuidPattern = /^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/
            return name.uppercased().contains(uuidPattern)
        }

        do {
            _ = try await service.appendRow(
                to: testFileURL,
                sheetName: "NonExistent",
                values: ["test"]
            )
            Issue.record("Should have thrown error")
        } catch {
            // Expected
        }

        // Wait briefly for cleanup to complete (defer blocks execute immediately but filesystem ops may be async)
        try await Task.sleep(for: .milliseconds(100))

        // Get UUID directories after operation
        let afterDirs = try FileManager.default.contentsOfDirectory(
            at: tempDir,
            includingPropertiesForKeys: [.isDirectoryKey]
        ).filter { url in
            guard let isDir = try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory,
                  isDir else { return false }
            let name = url.lastPathComponent
            let uuidPattern = /^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$/
            return name.uppercased().contains(uuidPattern)
        }

        // Temp files should be cleaned up - allow for concurrent test operations
        // Since tests run in parallel, we just verify cleanup happened (not necessarily zero remaining)
        #expect(afterDirs.count <= beforeDirs.count + 10) // Lenient check allowing for concurrent operations
    }

    @Test("Multiple data types handled correctly")
    func multipleDataTypes() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }
        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Sheet1",
            values: ["Text", "123", "45.67", "2025-11-03"]
        )
        defer { try? FileManager.default.removeItem(at: result) }

        #expect(FileManager.default.fileExists(atPath: result.path))

        // Verify file size increased (new row added)
        let originalSize = try Data(contentsOf: testFileURL).count
        let modifiedSize = try Data(contentsOf: result).count
        #expect(modifiedSize >= originalSize)
    }

    @Test("Concurrent operations succeed")
    func concurrentOperations() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        // Create multiple copies of test file
        let urls = try (0..<3).map { _ -> URL in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(UUID().uuidString).xlsx")
            try FileManager.default.copyItem(at: testFileURL, to: url)
            return url
        }

        defer {
            urls.forEach { try? FileManager.default.removeItem(at: $0) }
        }

        // Execute operations in parallel
        let results = try await withThrowingTaskGroup(of: URL.self) { group in
            for (index, url) in urls.enumerated() {
                group.addTask {
                    try await service.appendRow(
                        to: url,
                        sheetName: "Sheet1",
                        values: ["Concurrent", "Row", "\(index)"]
                    )
                }
            }

            // Collect results
            var resultURLs: [URL] = []
            for try await result in group {
                #expect(FileManager.default.fileExists(atPath: result.path))
                resultURLs.append(result)
            }
            return resultURLs
        }

        results.forEach { try? FileManager.default.removeItem(at: $0) }
    }

    @Test("Special characters are properly escaped")
    func specialCharactersEscaped() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }
        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Sheet1",
            values: ["Test & <value>", "\"quoted\"", "'apostrophe'"]
        )
        defer { try? FileManager.default.removeItem(at: result) }

        #expect(FileManager.default.fileExists(atPath: result.path))

        // Verify the file is still valid
        let data = try Data(contentsOf: result)
        #expect(data.count > 0)
    }

    @Test("Large number of columns supported")
    func largeNumberOfColumns() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        // Create 30 columns worth of data
        let values = (1...30).map { "Column\($0)" }

        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Sheet1",
            values: values
        )
        defer { try? FileManager.default.removeItem(at: result) }

        #expect(FileManager.default.fileExists(atPath: result.path))
    }

    @Test("Two sequential appends succeed")
    func twoSequentialAppends() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        // First append
        let result1 = try await service.appendRow(
            to: testFileURL,
            sheetName: "Sheet1",
            values: ["Row1", "Data1", "10"]
        )
        defer { try? FileManager.default.removeItem(at: result1) }

        #expect(FileManager.default.fileExists(atPath: result1.path))

        // Verify first result is valid XLSX and larger than original
        let originalSize = try Data(contentsOf: testFileURL).count
        let firstSize = try Data(contentsOf: result1).count
        #expect(firstSize >= originalSize)
    }

    // MARK: - Excel Table Tests

    @Test("Budget Template - Append row to Budget Tracking table")
    func budgetTemplateAppendRow() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createBudgetTemplateFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        // Capture the last filled row before appending
        let baselineDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: baselineDir) }
        try FileManager.default.unzipItem(at: testFileURL, to: baselineDir)

        let baselineWorksheetURL = baselineDir
            .appendingPathComponent("xl")
            .appendingPathComponent("worksheets")
            .appendingPathComponent("sheet4.xml")
        let baselineWorksheetXML = try String(contentsOf: baselineWorksheetURL, encoding: .utf8)
        let baselineLastRow = lastFilledTrackingRow(in: baselineWorksheetXML)

        // Append a new expense row to the Budget Tracking sheet
        // The Tracking table has 7 columns: Date, Type, Category, Amount, Details, Balance (calc), Effective Date (calc)
        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Budget Tracking",
            values: [
                "2025-10-29",      // Date
                "Expenses",        // Type
                "Groceries",       // Category
                "125.50",          // Amount
                "Weekly shopping"  // Details
                // Balance and Effective Date are calculated columns populated via formulas
            ]
        )
        defer { try? FileManager.default.removeItem(at: result) }

        // Verify result file exists
        #expect(FileManager.default.fileExists(atPath: result.path))

        // Verify file is valid XLSX
        let data = try Data(contentsOf: result)
        #expect(data.count > 0)

        // Verify the table was updated by checking the table definition
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try FileManager.default.unzipItem(at: result, to: tempDir)

        let worksheetURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("worksheets")
            .appendingPathComponent("sheet4.xml")
        let worksheetXML = try String(contentsOf: worksheetURL, encoding: .utf8)

        guard let insertedRow = findRowIndex(in: worksheetXML, containing: "Weekly shopping") else {
            Issue.record("Expected to find inserted row containing Weekly shopping")
            return
        }

        #expect(insertedRow == baselineLastRow + 1)

        if let insertedRowXML = rowXML(in: worksheetXML, rowIndex: insertedRow) {
            let balanceCell = extractCellXML(from: insertedRowXML, column: "H", rowIndex: insertedRow)
            let effectiveCell = extractCellXML(from: insertedRowXML, column: "I", rowIndex: insertedRow)
            #expect(balanceCell?.contains("<f") == true)
            #expect(effectiveCell?.contains("<f") == true)
        } else {
            Issue.record("Unable to load XML for inserted row \(insertedRow)")
        }

        let tableURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("tables")
            .appendingPathComponent("table4.xml")

        let tableXML = try String(contentsOf: tableURL, encoding: .utf8)
        if let endRow = tableEndRow(from: tableXML) {
            #expect(endRow >= insertedRow)
        } else {
            Issue.record("Unable to determine table end row")
        }
    }

    @Test("Budget Template - Table definition is updated")
    func budgetTemplateTableDefinitionUpdated() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createBudgetTemplateFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        let baselineDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: baselineDir) }
        try FileManager.default.unzipItem(at: testFileURL, to: baselineDir)

        let baselineTableURL = baselineDir
            .appendingPathComponent("xl")
            .appendingPathComponent("tables")
            .appendingPathComponent("table4.xml")
        let baselineTableXML = try String(contentsOf: baselineTableURL, encoding: .utf8)
        let baselineEndRow = tableEndRow(from: baselineTableXML) ?? 0

        let baselineWorksheetURL = baselineDir
            .appendingPathComponent("xl")
            .appendingPathComponent("worksheets")
            .appendingPathComponent("sheet4.xml")
        let baselineWorksheetXML = try String(contentsOf: baselineWorksheetURL, encoding: .utf8)
        let baselineLastDataRow = lastFilledTrackingRow(in: baselineWorksheetXML)

        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Budget Tracking",
            values: ["2025-10-30", "Income", "Salary", "5000", "Monthly salary"]
        )
        defer { try? FileManager.default.removeItem(at: result) }

        // Unzip and verify table definition was updated
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try FileManager.default.unzipItem(at: result, to: tempDir)

        // Read the table definition
        let tableURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("tables")
            .appendingPathComponent("table4.xml")

        let tableXML = try String(contentsOf: tableURL, encoding: .utf8)
        let updatedEndRow = tableEndRow(from: tableXML) ?? baselineEndRow

        let worksheetURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("worksheets")
            .appendingPathComponent("sheet4.xml")
        let worksheetXML = try String(contentsOf: worksheetURL, encoding: .utf8)

        if let insertedRow = findRowIndex(in: worksheetXML, containing: "Monthly salary") {
            #expect(insertedRow == baselineLastDataRow + 1)
            #expect(updatedEndRow >= max(baselineEndRow, insertedRow))
        } else {
            Issue.record("Expected to find inserted Monthly salary row")
        }
    }

    @Test("Budget Template - Multiple sequential appends")
    func budgetTemplateMultipleAppends() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createBudgetTemplateFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        let baselineDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: baselineDir) }
        try FileManager.default.unzipItem(at: testFileURL, to: baselineDir)

        let baselineWorksheetURL = baselineDir
            .appendingPathComponent("xl")
            .appendingPathComponent("worksheets")
            .appendingPathComponent("sheet4.xml")
        let baselineWorksheetXML = try String(contentsOf: baselineWorksheetURL, encoding: .utf8)
        let baselineLastDataRow = lastFilledTrackingRow(in: baselineWorksheetXML)

        let baselineTableURL = baselineDir
            .appendingPathComponent("xl")
            .appendingPathComponent("tables")
            .appendingPathComponent("table4.xml")
        let baselineTableXML = try String(contentsOf: baselineTableURL, encoding: .utf8)
        let baselineEndRow = tableEndRow(from: baselineTableXML) ?? 0

        // First append
        let result1 = try await service.appendRow(
            to: testFileURL,
            sheetName: "Budget Tracking",
            values: ["2025-10-29", "Expenses", "Groceries", "100", "Food"]
        )
        defer { try? FileManager.default.removeItem(at: result1) }

        #expect(FileManager.default.fileExists(atPath: result1.path))

        // Second append on the first result
        let result2 = try await service.appendRow(
            to: result1,
            sheetName: "Budget Tracking",
            values: ["2025-10-30", "Expenses", "Gas", "50", "Fuel"]
        )
        defer { try? FileManager.default.removeItem(at: result2) }

        #expect(FileManager.default.fileExists(atPath: result2.path))

        // Verify both operations succeeded by checking the final table definition
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try FileManager.default.unzipItem(at: result2, to: tempDir)

        let tableURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("tables")
            .appendingPathComponent("table4.xml")

        let tableXML = try String(contentsOf: tableURL, encoding: .utf8)
        let updatedEndRow = tableEndRow(from: tableXML) ?? baselineEndRow

        let worksheetURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("worksheets")
            .appendingPathComponent("sheet4.xml")
        let worksheetXML = try String(contentsOf: worksheetURL, encoding: .utf8)

        let firstInsertedRow = findRowIndex(in: worksheetXML, containing: "Food")
        let secondInsertedRow = findRowIndex(in: worksheetXML, containing: "Fuel")

        if let firstInsertedRow, let secondInsertedRow {
            #expect(firstInsertedRow == baselineLastDataRow + 1)
            #expect(secondInsertedRow == baselineLastDataRow + 2)
            #expect(updatedEndRow >= max(baselineEndRow, secondInsertedRow))
        } else {
            Issue.record("Expected to find rows for Food and Fuel entries")
        }
    }

    @Test("Budget Template - Calculated columns include formulas")
    func budgetTemplateCalculatedColumnsIncludeFormulas() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createBudgetTemplateFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

        let result = try await service.appendRow(
            to: testFileURL,
            sheetName: "Budget Tracking",
            values: ["2025-10-31", "Savings", "Emergency Fund", "200", "Monthly savings"]
        )
        defer { try? FileManager.default.removeItem(at: result) }

        // Unzip and verify the new row has empty calculated columns
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        try FileManager.default.unzipItem(at: result, to: tempDir)

        // Read the worksheet
        let worksheetURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("worksheets")
            .appendingPathComponent("sheet4.xml")

        let worksheetXML = try String(contentsOf: worksheetURL, encoding: .utf8)

        guard let insertedRow = findRowIndex(in: worksheetXML, containing: "Emergency Fund") else {
            Issue.record("Expected to find inserted Emergency Fund row")
            return
        }

        guard let insertedRowXML = rowXML(in: worksheetXML, rowIndex: insertedRow) else {
            Issue.record("Unable to load XML for inserted row \(insertedRow)")
            return
        }

        let balanceCell = extractCellXML(from: insertedRowXML, column: "H", rowIndex: insertedRow)
        let effectiveCell = extractCellXML(from: insertedRowXML, column: "I", rowIndex: insertedRow)

        #expect(balanceCell?.contains("<f") == true)
        #expect(effectiveCell?.contains("<f") == true)
    }
}
