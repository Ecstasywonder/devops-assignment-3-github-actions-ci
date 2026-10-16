#!/usr/bin/env bash

# Assignment 3: Bash syntax and project structure validation

set -uo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR" || exit 1

PASS=0
FAIL=0

pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}

echo "======================================"
echo " Assignment 3 - Bash Linter"
echo "======================================"

required_files=(
    "README.md"
    "app/app.sh"
    "scripts/lint.sh"
    "scripts/build.sh"
    "tests/test.sh"
    "Dockerfile"
    "compose.yaml"
    ".dockerignore"
    ".github/workflows/ci.yml"
)

for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        pass "Required file exists: $file"
    else
        fail "Missing required file: $file"
    fi
done

for file in app/*.sh scripts/*.sh tests/*.sh; do
    [[ -f "$file" ]] || continue

    if bash -n "$file"; then
        pass "Bash syntax: $file"
    else
        fail "Bash syntax: $file"
    fi
done

echo
echo "Passed: $PASS"
echo "Failed: $FAIL"

(( FAIL == 0 ))
