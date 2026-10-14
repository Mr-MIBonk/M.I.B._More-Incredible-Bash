#!/bin/bash
# Quick syntax and basic validation for M.I.B. fixes
# Run this before committing

WORKSPACE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=========================================="
echo "M.I.B. Quick Validation Check"
echo "=========================================="
echo ""

FILES=(
    "esd/scripts/svm.sh"
    "apps/svm"
    "apps/flash"
    "apps/backup"
)

PASSED=0
FAILED=0

echo "Checking modified files for syntax errors..."
echo ""

for file in "${FILES[@]}"; do
    filepath="$WORKSPACE_ROOT/$file"
    if [ -f "$filepath" ]; then
        printf "  %-30s " "$file"
        if bash -n "$filepath" 2>/dev/null; then
            echo -e "${GREEN}✅ OK${NC}"
            ((PASSED++))
        else
            echo -e "${RED}❌ SYNTAX ERROR${NC}"
            ((FAILED++))
            echo ""
            echo "Details:"
            bash -n "$filepath"
            echo ""
        fi
    else
        printf "  %-30s " "$file"
        echo -e "${YELLOW}⚠️  NOT FOUND${NC}"
    fi
done

echo ""
echo "=========================================="
echo "Results"
echo "=========================================="
echo -e "Passed: ${GREEN}$PASSED${NC}/4"
echo -e "Failed: ${RED}$FAILED${NC}/4"
echo "=========================================="
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All syntax checks passed!${NC}"
    echo ""
    echo "Your fixes are ready for commit."
    echo ""
    echo "Next steps:"
    echo "  1. git add esd/scripts/svm.sh apps/svm apps/flash apps/backup tests/"
    echo "  2. git commit -m \"fix(critical): Eliminate race conditions and fix flash validation\""
    echo "  3. git push origin main"
    echo "  4. Create pull request on GitHub"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Syntax errors found! Please fix before committing.${NC}"
    echo ""
    exit 1
fi
