#!/bin/bash

# iOS Feature Structure Generator
# Creates standard directory structure for new features following Feature-Scoped Architecture

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <FeatureName>"
    echo "Example: $0 GameLibrary"
    exit 1
fi

FEATURE_NAME="$1"
BASE_DIR="rulebook-kit/Sources/Features/${FEATURE_NAME}Feature"

echo "Creating feature structure for: ${FEATURE_NAME}Feature"
echo "Location: ${BASE_DIR}"

# Create directory structure
mkdir -p "${BASE_DIR}/Data/DTOs"
mkdir -p "${BASE_DIR}/Data/DataSources"
mkdir -p "${BASE_DIR}/Data/Repositories"
mkdir -p "${BASE_DIR}/Domain/Errors"
mkdir -p "${BASE_DIR}/Domain/Protocols"
mkdir -p "${BASE_DIR}/Infrastructure/Analytics"
mkdir -p "${BASE_DIR}/Infrastructure/Mocks"
mkdir -p "${BASE_DIR}/Presentation/Views"

echo "✅ Created feature directory structure:"
echo "   ${BASE_DIR}/"
echo "   ├── Data/"
echo "   │   ├── DTOs/"
echo "   │   ├── DataSources/"
echo "   │   └── Repositories/"
echo "   ├── Domain/"
echo "   │   ├── Errors/"
echo "   │   └── Protocols/"
echo "   ├── Infrastructure/"
echo "   │   ├── Analytics/"
echo "   │   └── Mocks/"
echo "   └── Presentation/"
echo "       └── Views/"
echo ""
echo "Next steps:"
echo "1. Create feature-scoped entity in rulebook-kit/Sources/Entities/ (if needed)"
echo "2. Implement DTO in Data/DTOs/"
echo "3. Define errors in Domain/Errors/"
echo "4. Create protocols in Domain/Protocols/"
echo "5. Implement data sources, repository, and TCA reducer"
echo ""
echo "Refer to references/feature-structure.md for detailed implementation guide"
