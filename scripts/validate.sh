#!/bin/bash
#
# ReceiptVault Pre-Commit Validation Script
# Run this BEFORE every commit to ensure CI will pass
#
# Usage: ./scripts/validate.sh
#

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "  ReceiptVault Pre-Commit Validation"
echo "  Project: $PROJECT_ROOT"
echo "=========================================="
echo ""

# Track if any step fails
FAILED=0

# 1. Format code
echo -e "${YELLOW}[1/6] Formatting Dart code...${NC}"
dart format . || { echo -e "${RED}Format failed${NC}"; FAILED=1; }
echo ""

# 2. Run Flutter analyze
echo -e "${YELLOW}[2/6] Running Flutter analyze...${NC}"
flutter analyze --no-fatal-infos --no-fatal-warnings || { echo -e "${RED}Analyze failed${NC}"; FAILED=1; }
echo ""

# 3. Run Flutter tests (skip if no test directory)
echo -e "${YELLOW}[3/6] Running Flutter tests...${NC}"
if [ -d "test" ]; then
    flutter test || { echo -e "${RED}Tests failed${NC}"; FAILED=1; }
else
    echo "No test directory found, skipping tests"
fi
echo ""

# 4. Run Cloud Functions lint
echo -e "${YELLOW}[4/6] Running Cloud Functions lint...${NC}"
if [ -d "functions" ] && [ -f "functions/package.json" ]; then
    (cd functions && npm run lint) || { echo -e "${RED}Functions lint failed${NC}"; FAILED=1; }
else
    echo "Functions directory not found, skipping"
fi
echo ""

# 5. Run Cloud Functions build
echo -e "${YELLOW}[5/6] Building Cloud Functions...${NC}"
if [ -d "functions" ] && [ -f "functions/package.json" ]; then
    (cd functions && npm run build) || { echo -e "${RED}Functions build failed${NC}"; FAILED=1; }
else
    echo "Functions directory not found, skipping"
fi
echo ""

# 6. Verify format check passes (CI uses --set-exit-if-changed)
echo -e "${YELLOW}[6/6] Verifying format (CI mode)...${NC}"
dart format --output=none --set-exit-if-changed . || {
    echo -e "${RED}Format check failed - files were changed by format${NC}"
    echo "Run 'dart format .' and commit the changes"
    FAILED=1
}
echo ""

# Summary
echo "=========================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}  All validations passed!${NC}"
    echo "  Safe to commit and push."
else
    echo -e "${RED}  Validation FAILED${NC}"
    echo "  Fix the issues above before committing."
    exit 1
fi
echo "=========================================="
