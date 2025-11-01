#!/bin/bash

# iOS Service Structure Generator
# Creates standard directory structure for new services following the service pattern

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <ServiceName>"
    echo "Example: $0 CustomCamera"
    exit 1
fi

SERVICE_NAME="$1"
BASE_DIR="rulebook-kit/Sources/Services/${SERVICE_NAME}Service"

echo "Creating service structure for: ${SERVICE_NAME}Service"
echo "Location: ${BASE_DIR}"

# Create directory structure
mkdir -p "${BASE_DIR}/Interface"
mkdir -p "${BASE_DIR}/Live"
mkdir -p "${BASE_DIR}/Mock"

echo "✅ Created service directory structure:"
echo "   ${BASE_DIR}/"
echo "   ├── Interface/"
echo "   ├── Live/"
echo "   └── Mock/"
echo ""
echo "Next steps:"
echo "1. Create protocol in Interface/${SERVICE_NAME}ServiceProtocol.swift"
echo "2. Implement live service in Live/${SERVICE_NAME}Service.swift"
echo "3. Create mock in Mock/Mock${SERVICE_NAME}Service.swift"
echo "4. Register dependency in ${SERVICE_NAME}ServiceDependency.swift"
echo "5. Add service-specific errors to Framework/AppError.swift (if needed)"
echo ""
echo "Refer to references/service-implementation.md for detailed implementation guide"
