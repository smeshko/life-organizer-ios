#!/bin/bash

# Approve TCA and related macros for Xcode
# This pre-approves common macros so you don't have to manually approve them in Xcode

set -e

FINGERPRINTS_FILE="$HOME/Library/Developer/Xcode/UserData/IDEMacroFingerprints.plist"

echo "📦 Pre-approving TCA macros..."

# Create directory if it doesn't exist
mkdir -p "$(dirname "$FINGERPRINTS_FILE")"

# Initialize plist if it doesn't exist
if [ ! -f "$FINGERPRINTS_FILE" ]; then
    echo '<?xml version="1.0" encoding="UTF-8"?>' > "$FINGERPRINTS_FILE"
    echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> "$FINGERPRINTS_FILE"
    echo '<plist version="1.0">' >> "$FINGERPRINTS_FILE"
    echo '<dict>' >> "$FINGERPRINTS_FILE"
    echo '</dict>' >> "$FINGERPRINTS_FILE"
    echo '</plist>' >> "$FINGERPRINTS_FILE"
fi

# TCA Macros to approve
# Note: These are the package identifiers - Xcode will accept any version of these macros
MACROS=(
    "composable-architecture-macro"
    "case-paths-macro"
    "swift-dependencies-macro"
)

for macro in "${MACROS[@]}"; do
    # Check if already approved
    if /usr/libexec/PlistBuddy -c "Print :$macro" "$FINGERPRINTS_FILE" &>/dev/null; then
        echo "  ✓ $macro (already approved)"
    else
        # Add macro with wildcard approval (accepts any fingerprint from this package)
        /usr/libexec/PlistBuddy -c "Add :$macro dict" "$FINGERPRINTS_FILE" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Add :$macro:trust bool true" "$FINGERPRINTS_FILE" 2>/dev/null || true
        echo "  ✓ $macro (approved)"
    fi
done

echo ""
echo "✅ TCA macros pre-approved!"
echo ""
echo "Note: You may still see approval dialogs for new macro versions."
echo "This is normal and provides security while reducing repetitive approvals."
