run_audit() {
    for id in "${!IDS[@]}"; do
        audit_res=$(bash -c "${ACOMMAND[$id]}")
        if [[ "$audit_res" =~ "${EXPECTED[$id]}" ]]; then
            CHECK="PASS"
        else
            CHECK="FAIL"
        fi
        write_report "${IDS[$id]}" "${TITLE[$id]}" "$CHECK"
}