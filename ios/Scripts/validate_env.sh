#!/bin/bash
# Environment Validation Script for iOS Builds
# This script runs automatically before Xcode builds
# DO NOT DELETE - Required for production safety

set -e

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  🔍 Running Environment Validation (iOS)                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Get the Flutter project root (go up from ios/ directory)
FLUTTER_ROOT="${SRCROOT}/.."

# Check if building for release
if [ "${CONFIGURATION}" != "Release" ] && [ "${CONFIGURATION}" != "Profile" ]; then
    echo "ℹ️  Debug build detected - skipping validation"
    echo ""
    exit 0
fi

echo "⚠️  Release build detected - validating environment..."
echo ""

# Run the Dart validator
cd "${FLUTTER_ROOT}"

if ! dart run tool/env_validator.dart; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  ❌ CRITICAL: iOS Build Aborted                              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Environment validation failed!"
    echo "Update lib/config/env.dart and try again."
    echo ""
    exit 1
fi

echo ""
echo "✅ Environment validation completed successfully (iOS)"
echo ""

exit 0
