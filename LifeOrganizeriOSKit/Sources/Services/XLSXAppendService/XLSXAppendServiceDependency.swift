import Dependencies

/// TCA dependency key for XLSXAppendService
private enum XLSXAppendServiceKey: DependencyKey {
    /// Live implementation for production
    static let liveValue: any XLSXAppendServiceProtocol = XLSXAppendService()

    /// Mock implementation for tests
    static let testValue: any XLSXAppendServiceProtocol = MockXLSXAppendService()
}

/// Extension to make XLSXAppendService available via TCA's dependency system
public extension DependencyValues {
    /// Access to the XLSX append service
    ///
    /// Usage in a TCA feature:
    /// ```swift
    /// @Dependency(\.xlsxAppendService) var xlsxAppendService
    ///
    /// let modifiedURL = try await xlsxAppendService.appendRow(
    ///     to: fileURL,
    ///     sheetName: "Budget",
    ///     values: ["2025-11-03", "Groceries", "45.67"]
    /// )
    /// ```
    var xlsxAppendService: any XLSXAppendServiceProtocol {
        get { self[XLSXAppendServiceKey.self] }
        set { self[XLSXAppendServiceKey.self] = newValue }
    }
}
