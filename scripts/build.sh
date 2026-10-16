#!/usr/bin/env bash

# Assignment 3: Docker build and smoke tests

set -uo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="assignment3-devops-ci:local"

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

run_test() {
    local name="$1"
    local expected="$2"
    local pattern="$3"
    shift 3

    local output
    local actual

    output=$("$@" 2>&1)
    actual=$?

    if [[ "$actual" -eq "$expected" ]] &&
       [[ "$output" == *"$pattern"* ]]; then
        pass "$name"
    else
        fail "$name (expected exit $expected, got $actual)"
        echo "$output"
    fi
}

echo "======================================"
echo " Assignment 3 - Docker Build Tests"
echo "======================================"

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon unavailable" >&2
    exit 1
fi

echo "Building Docker image..."

if ! docker build -t "$IMAGE" .; then
    echo "ERROR: Docker build failed" >&2
    exit 1
fi

run_test "Docker help" 0 "Usage:" \
    docker run --rm "$IMAGE" help

run_test "Docker system-info" 0 "SYSTEM INFORMATION" \
    docker run --rm "$IMAGE" system-info

run_test "Docker invalid command" 2 "Unknown command" \
    docker run --rm "$IMAGE" invalid-command

run_test "Docker missing command" 2 "Missing command" \
    docker run --rm --entrypoint /bin/bash \
    "$IMAGE" /opt/devops/app.sh

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

(( FAIL == 0 ))
