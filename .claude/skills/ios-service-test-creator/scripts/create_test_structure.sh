#!/bin/bash

# iOS Service Test Structure Generator
# Creates standard directory structure for service tests

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <ServiceName>"
    echo "Example: $0 Network"
    exit 1
fi

SERVICE_NAME="$1"
BASE_DIR="rulebook-kit/Tests/${SERVICE_NAME}ServiceTests"

echo "Creating test structure for: ${SERVICE_NAME}ServiceTests"
echo "Location: ${BASE_DIR}"

# Create directory structure
mkdir -p "${BASE_DIR}/Helpers"

echo "✅ Created test directory structure:"
echo "   ${BASE_DIR}/"
echo "   └── Helpers/"
echo ""
echo "Next steps:"
echo "1. Create Mock{Protocol}.swift in Helpers/"
echo "2. Create Test{Domain}Models.swift in Helpers/ (with sample data)"
echo "3. Create Test{Service}Fixtures.swift in Helpers/ (if needed)"
echo "4. Create {Service}{Method}Tests.swift for each public method"
echo "5. Create {Service}ErrorHandlingTests.swift for consistency"
echo "6. Update Package.swift to add test target"
echo ""
echo "Refer to references/test-implementation.md for detailed implementation guide"
