
# Parser function
parse_benchmark() {
    FILE="$1"
    echo "File is ${FILE}"
    while IFS=$'\t' read -r id title level automated aCommand expected; do
        IDS+=("$id")
        TITLE+=("$title")
        LEVEL+=("$level")
        AUTOMATED+=("$automated")
        ACOMMAND+=("$aCommand")
        EXPECTED+=("$expected")
    done < <(yq -r '.controls[] | [
        .id // "",
        .title // "",
        .level // "",
        .automated // "",
        .audit.command // "",
        .audit.expected // ""
        ] | @tsv' "$FILE"
    )
}