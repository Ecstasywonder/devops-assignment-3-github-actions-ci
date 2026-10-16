#!/usr/bin/env bash

# Assignment 3: Automated diagnostic CLI tests

set -uo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$PROJECT_DIR/app/app.sh"

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
echo " Assignment 3 - Automated Tests"
echo "======================================"

if [[ ! -x "$APP" ]]; then
    echo "ERROR: Application missing or not executable" >&2
    exit 1
fi

run_test "Help command" 0 "Usage:" \
    "$APP" help

run_test "System information" 0 "SYSTEM INFORMATION" \
    "$APP" system-info

run_test "Invalid command" 2 "Unknown command" \
    "$APP" invalid-command

run_test "Missing command" 2 "Missing command" \
    "$APP"

run_test "Missing host" 2 "requires one hostname" \
    "$APP" check-host

run_test "Invalid hostname" 2 "Invalid hostname" \
    "$APP" check-host "invalid host"

run_test "Missing port" 2 "requires a host and port" \
    "$APP" check-port localhost

run_test "Non-numeric port" 2 "Port must" \
    "$APP" check-port localhost abc

run_test "Port zero" 2 "Port must" \
    "$APP" check-port localhost 0

run_test "Port above range" 2 "Port must" \
    "$APP" check-port localhost 65536

run_test "Extra help argument" 2 "accepts no arguments" \
    "$APP" help unexpected

# DNS resolution should work for localhost.
# ICMP success is not guaranteed on every CI runner.
output=$("$APP" check-host localhost 2>&1)
rc=$?

if [[ "$output" == *"Resolved IP"* ]] &&
   [[ "$rc" -eq 0 || "$rc" -eq 1 ]]; then
    pass "Valid localhost resolution"
else
    fail "Valid localhost resolution"
    echo "$output"
fi

echo
echo "======================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "======================================"

(( FAIL == 0 ))
