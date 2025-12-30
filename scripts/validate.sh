#!/bin/bash
# Phase Validation Script
# Run this before creating a PR to ensure all checks pass

set -e

echo "========================================"
echo "🚀 ReceiptVault Phase Validation"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
    echo ""
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Step 1: Generate Drift code
step "Generating Drift database code..."
dart run build_runner build --delete-conflicting-outputs || error "Code generation failed"
success "Code generation complete"

# Step 2: Generate localization
step "Generating localization files..."
flutter gen-l10n || error "Localization generation failed"
success "Localization generation complete"

# Step 3: Verify generated files
step "Verifying generated files exist..."
if [ ! -f "lib/data/datasources/local/database/app_database.g.dart" ]; then
    error "Drift database file not found"
fi
if [ ! -f "lib/l10n/generated/app_localizations.dart" ]; then
    error "Localization files not found"
fi
success "All generated files present"

# Step 4: Run analysis
step "Running static analysis..."
flutter analyze || error "Analysis found issues"
success "Static analysis passed"

# Step 5: Check formatting
step "Checking code formatting..."
dart format --set-exit-if-changed . || error "Code formatting issues found. Run 'dart format .' to fix"
success "Code formatting correct"

# Step 6: Run tests
step "Running unit tests..."
flutter test || error "Tests failed"
success "All tests passed"

# Step 7: Check Cloud Functions (if directory exists)
if [ -d "functions" ]; then
    step "Validating Cloud Functions..."
    cd functions
    npm run lint || error "Functions lint failed"
    npm run build || error "Functions build failed"
    npm test || error "Functions tests failed"
    cd ..
    success "Cloud Functions validation passed"
fi

echo "========================================"
echo -e "${GREEN}🎉 All validations passed!${NC}"
echo "========================================"
echo ""
echo "You can now create your PR with confidence."
