# Testing XLSXAppendService with Budget Template

## Quick Test Options

### Option 1: Run the Unit Tests ✅ (Already Passing!)
```bash
cd /Users/A1E6E98/Developer/life-organizer/LifeOrganizeriOS/LifeOrganizeriOSKit
swift test --filter XLSXAppendServiceTests
```

All 16 tests pass, including 4 Budget Template tests!

### Option 2: Test with a Real File

1. **Copy your budget file to a test location:**
```bash
cp "/Users/A1E6E98/Downloads/Documents/Ultimate Personal Budget Extended.xlsx" /tmp/test_budget.xlsx
```

2. **Create a simple Swift file to test:**
```swift
// Save as TestXLSX.swift in your project
import Foundation
import XLSXAppendService

@main
struct TestXLSX {
    static func main() async throws {
        let service = XLSXAppendService()

        let inputURL = URL(fileURLWithPath: "/tmp/test_budget.xlsx")

        print("📊 Testing XLSXAppendService...")
        print("Input: \(inputURL.path)")

        let result = try await service.appendRow(
            to: inputURL,
            sheetName: "Budget Tracking",
            values: [
                "2025-11-04",           // Date
                "Expenses",             // Type
                "Testing",              // Category
                "42.00",                // Amount
                "Test from CLI"         // Details
                // Balance and Effective Date are calculated automatically!
            ]
        )

        print("✅ Success! Output: \(result.path)")
        print("📂 Open the file in Excel to verify:")
        print("   - New row added at the bottom of the Tracking table")
        print("   - Balance column auto-calculated")
        print("   - Effective Date column auto-calculated")
        print("   - Table range extended to include new row")
    }
}
```

3. **Run it:**
```bash
cd /Users/A1E6E98/Developer/life-organizer/LifeOrganizeriOS/LifeOrganizeriOSKit
swift run TestXLSX
```

### Option 3: Add a Test Button to Your iOS App

Add this to your existing AppFeature:

```swift
import XLSXAppendService

// In your reducer
case .testBudgetAppend:
    return .run { send in
        let service = XLSXAppendService()

        // Get the budget file URL (from Documents or bundled resource)
        guard let budgetURL = getBudgetFileURL() else {
            await send(.showError("Budget file not found"))
            return
        }

        do {
            let result = try await service.appendRow(
                to: budgetURL,
                sheetName: "Budget Tracking",
                values: [
                    Date().formatted(.iso8601),  // Today's date
                    "Expenses",
                    "Test Expense",
                    "10.00",
                    "App test"
                ]
            )

            await send(.appendSuccess(result))
        } catch {
            await send(.showError(error.localizedDescription))
        }
    }
```

### Option 4: Interactive Testing in Xcode Playground

1. Open Xcode
2. Create a new Playground
3. Import your package
4. Test interactively:

```swift
import XLSXAppendService
import Foundation

let service = XLSXAppendService()
let budgetFile = URL(fileURLWithPath: "/tmp/test_budget.xlsx")

Task {
    let result = try await service.appendRow(
        to: budgetFile,
        sheetName: "Budget Tracking",
        values: ["2025-11-04", "Income", "Salary", "5000", "Monthly"]
    )
    print("✅ Row appended! Check: \(result.path)")
}
```

## What to Verify When You Open the File:

1. **Open the output file in Excel**
2. **Go to "Budget Tracking" sheet**
3. **Scroll to the bottom of the Tracking table**
4. **Verify:**
   - ✅ New row is added with your data
   - ✅ Balance column shows a calculated value (not empty!)
   - ✅ Effective Date shows a calculated date
   - ✅ Table auto-filter includes the new row
   - ✅ You can sort/filter the table including the new row

## Example Output:

```
Row 1334: 2025-10-29 | Expenses | Baby | 614 | ... | -3718 | 2025-10-29
Row 1335: 2025-11-04 | Expenses | Testing | 42 | ... | -3760 | 2025-11-04  ← NEW!
```

The Balance column automatically calculates based on all previous transactions!
