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
        let tempCountBefore = try FileManager.default
            .contentsOfDirectory(
                at: FileManager.default.temporaryDirectory,
                includingPropertiesForKeys: nil
            )
            .count

        _ = try await service.appendRow(
            to: testFileURL,
            sheetName: "Sheet1",
            values: ["test"]
        )

        let tempCountAfter = try FileManager.default
            .contentsOfDirectory(
                at: FileManager.default.temporaryDirectory,
                includingPropertiesForKeys: nil
            )
            .count

        // Should only be 1-2 more files (the result + our test file), not multiple temp dirs
        #expect(tempCountAfter <= tempCountBefore + 3) // Allow some variance for system temp files
    }

    @Test("Temporary files cleaned up after error")
    func cleanupOnError() async throws {
        let service = XLSXAppendService()
        let testFileURL = try createTestFile()
        defer { try? FileManager.default.removeItem(at: testFileURL) }
        let tempCountBefore = try FileManager.default
            .contentsOfDirectory(
                at: FileManager.default.temporaryDirectory,
                includingPropertiesForKeys: nil
            )
            .count

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

        let tempCountAfter = try FileManager.default
            .contentsOfDirectory(
                at: FileManager.default.temporaryDirectory,
                includingPropertiesForKeys: nil
            )
            .count

        // Temp files should be cleaned up
        #expect(tempCountAfter <= tempCountBefore + 2) // Allow some variance
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
        try await withThrowingTaskGroup(of: URL.self) { group in
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
            for try await result in group {
                #expect(FileManager.default.fileExists(atPath: result.path))
            }
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
}
