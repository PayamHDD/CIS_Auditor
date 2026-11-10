#!/bin/bash

# ==========================================
# CIS Auditor - Main Controller
# ==========================================

set -o pipefail

# 1. Load Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/hardening.conf" ]]; then
    echo "ERROR: hardening.conf not found." >&2
    exit 1
fi

source "$SCRIPT_DIR/hardening.conf"
ENGINE_DIR="$SCRIPT_DIR/$ENGINE_DIR"
BENCHMARK_DIR="$SCRIPT_DIR/$BENCHMARK_DIR"
REPORT_DIR="$SCRIPT_DIR/$REPORT_DIR"

# ==========================================
# 3. Check Dependencies
# ==========================================

check_dependencies() {
    # Check if Report directory is available
    if [[ ! -d "$REPORT_DIR" ]]; then
        mkdir "$REPORT_DIR"
    fi
    # check if yq package is available
    if ! command -v yq &>/dev/null; then
        echo "ERROR: yq is not installed." >&2
        echo "Install using: dnf install yq" >&2
        exit 1
    fi

}

# ==========================================
# 4. Check Permissions
# ==========================================

check_permissions() {

    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: Root privileges are required." >&2
        exit 1
    fi

}

# ==========================================
# 5. Help
# ==========================================

goHelp() {

    cat <<EOF
CIS Auditor

Usage:
    $0 <Command>
    Commanads:
    ----------
    -b, --benchmark <file>   Benchmark YAML file
    -a, --all                Audit all benchmarks (Awailable in benchmarks directory)
    -c, --control <id>       Audit specific control (Should be used with benchmark file)
    -h, --help               Show this help

Examples:
    $0 -b benchmarks/linux.yml          => Audit linux benchmark
    $0 -b benchmarks/linux.yml -c 1.1.1 => Audit control 1.1.1 from linux bechmark
    $0 -a                               => Audit all benchmarks

EOF

}

# ==========================================
# 6. Parse Arguments
# ==========================================

parse_arguments() {

    while [[ $# -gt 0 ]]; do

        case "$1" in

            --benchmark|-b)
                if [[ -z "${2:-}" || "$2" == -* ]]; then
                    echo "ERROR: --benchmark requires a benchmark name." >&2
                    exit 1
                fi
                BENCHMARK="$2"
                shift 2
                ;;

            --control|-c)
                if [[ -z "${2:-}" || "$2" == -* ]]; then
                    echo "ERROR: --control requires an ID." >&2
                    exit 1
                fi
                CONTROL="$2"
                shift 2
                ;;

            --all|-a)
                RUN_ALL=true
                shift
                ;;

            --help|-h)
                # IF --help used with other paramaters, all are ignored and 'Help Function' will be displayed
                goHelp
                exit 0
                ;;

            *)
                echo "ERROR: Unknown argument: $1" >&2
                goHelp
                exit 1
                ;;

        esac

    done

}

# ==========================================
# 7. Validate Arguments
# ==========================================

validate_arguments() {

    # Benchmark validation
    if [[ "$BENCHMARK" && "$RUN_ALL" == true ]]; then
        echo "ERROR: '--benchmark' can not be used with '--all'." >&2
        exit 1
    fi

    if [[ -z "$BENCHMARK" && "$RUN_ALL" != true ]]; then
        echo "ERROR: Benchmark file is required." >&2
        exit 1
    fi

    if [[ ! -f "$BENCHMARK" || ! -r "$BENCHMARK" ]]; then
        echo "ERROR: Benchmark file does not exist or is not readable." >&2
        exit 1
    fi


# ==========================================
# 8. Main Execution
# ==========================================

main() {

    # Check environment
    check_dependencies
    check_permissions

    # Parse and validate arguments
    parse_arguments "$@"
    validate_arguments

    # Initialize output directory
    mkdir -p "$REPORT_DIR" || {
        echo "ERROR: Cannot create report directory." >&2
        exit 1
    }

    # Parse Benchmark
    parse_benchmark "$BENCHMARK_DIR/$BENCHMARK"

    # Execute Audit
    run_audit

    # Generate Report
    generate_report

    # Summary
    show_summary

}

# ==========================================
# 9. Load Modules
# ==========================================

source "$ENGINE_DIR/parser.sh"
source "$ENGINE_DIR/audit.sh"
source "$ENGINE_DIR/reporter.sh"

# Run
main "$@"
