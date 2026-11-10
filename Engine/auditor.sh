run_audit() {
    for id in "${!IDS[@]}"; do
        audit_res=$()
        if [[ "$audit_res" == ""]]; then
            CHECK="PASS"

}