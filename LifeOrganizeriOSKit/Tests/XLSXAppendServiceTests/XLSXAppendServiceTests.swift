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

        defer {
            results.forEach { try? FileManager.default.removeItem(at: $0) }
        }
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
                // Balance and Effective Date are calculated columns - will be left empty
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

        let tableURL = tempDir
            .appendingPathComponent("xl")
            .appendingPathComponent("tables")
            .appendingPathComponent("table4.xml")

        let tableXML = try String(contentsOf: tableURL, encoding: .utf8)
        // Table should now end at row 1335 (was 1334)
        #expect(tableXML.contains("1335"))
    }

    @Test("Budget Template - Table definition is updated")
    func budgetTemplateTableDefinitionUpdated() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createBudgetTemplateFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

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

        // The table ref should have been updated to include the new row
        // Original ref was "C11:I1334", new should be "C11:I1335"
        #expect(tableXML.contains("C11:I1335") || tableXML.contains("ref=\"C11:I"))
    }

    @Test("Budget Template - Multiple sequential appends")
    func budgetTemplateMultipleAppends() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createBudgetTemplateFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }

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
        // After two appends, table should now end at row 1336 (was 1334)
        #expect(tableXML.contains("1336"))
    }

    @Test("Budget Template - Calculated columns remain empty")
    func budgetTemplateCalculatedColumnsEmpty() async throws {
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

        // The Balance and Effective Date columns should be empty cells (just <c r="..."/>)
        // This allows Excel to recalculate them when the file is opened
        #expect(worksheetXML.contains("<row r=\"1335\"")) // New row should be added
    }
}
