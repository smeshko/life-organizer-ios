import Foundation

/// Protocol defining the interface for appending rows to XLSX files
public protocol XLSXAppendServiceProtocol: Sendable {
    /// Appends a new row to the specified sheet in an XLSX file.
    ///
    /// This method:
    /// 1. Validates input parameters
    /// 2. Unzips the XLSX file
    /// 3. Locates the target worksheet by name
    /// 4. Finds the last row and appends a new row
    /// 5. Repackages the modified files into a new XLSX
    /// 6. Cleans up temporary files
    ///
    /// - Parameters:
    ///   - fileURL: URL to the source XLSX file (must be accessible)
    ///   - sheetName: Name of the target worksheet (must exist in workbook)
    ///   - values: Array of string values for the row (must not be empty)
    /// - Returns: URL to the modified XLSX file in a temporary location
    /// - Throws: AppError.xlsx for various failure scenarios:
    ///   - `.fileNotFound`: Source file not accessible
    ///   - `.invalidInputParameters`: Invalid sheet name or empty values
    ///   - `.sheetNotFound`: Sheet name doesn't exist
    ///   - `.zipOperationFailed`: ZIP/unzip operation failed
    ///   - `.xmlParsingFailed`: XML structure invalid
    ///   - `.worksheetModificationFailed`: Failed to modify worksheet
    func appendRow(
        to fileURL: URL,
        sheetName: String,
        values: [String]
    ) async throws -> URL
}
