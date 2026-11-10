run_audit() {
    for id in "${!IDS[@]}"; do

        if audit_res=$(bash -c "${ACOMMAND[$id]}" 2>/dev/null); then
            echo $audit_res
            if [[ "$audit_res" =~ ${EXPECTED[$id]} ]]; then
                CHECK="PASS"
            else
                CHECK="FAIL"
            fi

        else
            CHECK="ERROR"
        fi

        write_report "${IDS[$id]}" "${TITLE[$id]}" "$CHECK"

    done
}