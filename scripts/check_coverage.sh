THRESHOLD=${COV_THRESHOLD:=50}

RED_BG=$(tput setab 1)
GREEN_BG=$(tput setab 2)
NC=$(tput sgr0) # No Color

go_tool_cover_output=$(go tool cover -func=coverage.out)

if [[ $* == *verbose* ]]; then
    echo "$go_tool_cover_output"
fi

if (( $(echo "$go_tool_cover_output" | tail -n 1 | awk '{print $NF}' | grep -E "^[0-9]+" -o) >= THRESHOLD )); then
    echo -e "${GREEN_BG}[OK]${NC} Code coverage is OK"
    exit 0
else
    echo "$go_tool_cover_output"
    echo -e "${RED_BG}[FAIL]${NC} Code coverage have to be at least $THRESHOLD%"
    exit 1
fi
