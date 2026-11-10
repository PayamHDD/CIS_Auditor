# Parser function
parse_benchmark() {
    FILE="$1"
    while IFS=$'\t' read -r id title level type aCommand expected; do
        IDS+=("$id")
        TITLE+=("$title")
        LEVEL+=("$level")
        TYPE+=("$type")
        ACOMMAND+=("$aCommand")
        EXPECTED+=("$expected")
    done < <(yq -r '.controls[] | [
        .id // "",
        .title // "",
        .level // "",
        .type // "",
        .audit.command // "",
        .audit.expected // ""
        ] | @tsv' "$FILE"
    )
}