#!/usr/bin/env bash

# DevOps Assignment 3
# Linux diagnostic CLI for GitHub Actions CI/CD

set -uo pipefail

show_help() {
    cat <<'HELP'
========================================
        DEVOPS DIAGNOSTIC CLI
========================================

Usage:
  app.sh <command> [arguments]

Commands:
  system-info             Display Linux system information
  check-host <host>       Resolve and check a hostname or IP
  check-port <host> <port> Check TCP connectivity to a port
  help                    Display usage information

Exit Codes:
  0 = Success
  1 = Operational failure
  2 = Invalid command or input

Examples:
  ./app/app.sh system-info
  ./app/app.sh check-host localhost
  ./app/app.sh check-port localhost 22
  ./app/app.sh help
HELP
}

show_system_info() {
    echo "========================================"
    echo "           SYSTEM INFORMATION"
    echo "========================================"

    printf 'Hostname         : %s\n' "$(hostname)"
    printf 'Current User     : %s\n' "$(id -un)"
    printf 'Date/Time        : %s\n' "$(date)"
    printf 'Kernel Version   : %s\n' "$(uname -r)"

    # BusyBox and GNU uptime have different supported flags.
    printf 'Uptime           : %s\n' \
        "$(uptime -p 2>/dev/null || uptime)"

    if [[ -r /etc/os-release ]]; then
        (
            . /etc/os-release
            printf 'Operating System : %s\n' "${PRETTY_NAME:-Unknown}"
        )
    fi

    echo
    echo "CPU Cores:"
    nproc || return 1

    echo
    echo "Memory Information:"
    free -h || return 1

    echo "========================================"
}

validate_host() {
    local host="$1"

    if [[ -z "$host" ||
          "$host" == -* ||
          "$host" =~ [[:space:]] ||
          ! "$host" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
        echo "ERROR: Invalid hostname or IP address." >&2
        return 2
    fi

    return 0
}

validate_port() {
    local port="$1"

    if [[ ! "$port" =~ ^[0-9]+$ || ${#port} -gt 5 ]]; then
        echo "ERROR: Port must be an integer between 1 and 65535." >&2
        return 2
    fi

    port=$((10#$port))

    if (( port < 1 || port > 65535 )); then
        echo "ERROR: Port must be between 1 and 65535." >&2
        return 2
    fi

    return 0
}

resolve_host() {
    local host="$1"
    local resolved

    resolved=$(timeout 5 getent ahosts "$host" 2>/dev/null |
        awk 'NR==1 {print $1}')

    if [[ -z "$resolved" ]]; then
        echo "ERROR: Unable to resolve host: $host" >&2
        return 1
    fi

    printf '%s\n' "$resolved"
}

check_host() {
    local host="$1"
    local resolved

    validate_host "$host" || return $?

    resolved=$(resolve_host "$host") || return 1

    echo "========================================"
    echo "             HOST CHECK"
    echo "========================================"
    echo "Target Host : $host"
    echo "Resolved IP : $resolved"

    if timeout 5 ping -c 1 -W 2 "$resolved" >/dev/null 2>&1; then
        echo "Ping Status : SUCCESS"
        return 0
    else
        echo "Ping Status : FAILED or ICMP blocked"
        return 1
    fi
}

check_port() {
    local host="$1"
    local port="$2"
    local resolved

    validate_host "$host" || return $?
    validate_port "$port" || return $?

    # Normalize the validated numeric port.
    port=$((10#$port))

    resolved=$(resolve_host "$host") || return 1

    echo "========================================"
    echo "             TCP PORT CHECK"
    echo "========================================"
    echo "Target Host : $host"
    echo "Resolved IP : $resolved"
    echo "TCP Port    : $port"

    if timeout 5 bash -c \
        'exec 3<>/dev/tcp/$1/$2' _ "$resolved" "$port" 2>/dev/null; then
        echo "TCP Status  : OPEN"
        return 0
    else
        echo "TCP Status  : CLOSED or unreachable"
        return 1
    fi
}

main() {
    if (( $# == 0 )); then
        echo "ERROR: Missing command." >&2
        show_help >&2
        return 2
    fi

    local command="$1"
    shift

    case "$command" in
        help)
            if (( $# != 0 )); then
                echo "ERROR: help accepts no arguments." >&2
                return 2
            fi
            show_help
            ;;
        system-info)
            if (( $# != 0 )); then
                echo "ERROR: system-info accepts no arguments." >&2
                return 2
            fi
            show_system_info
            ;;
        check-host)
            if (( $# != 1 )); then
                echo "ERROR: check-host requires one hostname." >&2
                return 2
            fi
            check_host "$1"
            ;;
        check-port)
            if (( $# != 2 )); then
                echo "ERROR: check-port requires a host and port." >&2
                return 2
            fi
            check_port "$1" "$2"
            ;;
        *)
            echo "ERROR: Unknown command: $command" >&2
            show_help >&2
            return 2
            ;;
    esac
}

main "$@"
