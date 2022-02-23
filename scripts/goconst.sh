if ! [ -x "$(command -v goconst)" ]
then
    echo -e "${BLUE}Installing goconst${NC}"
    GO111MODULE=off go get github.com/jgautheron/goconst/cmd/goconst
fi

if [[ $(goconst -min-occurrences=3 ./... | tee /dev/tty | wc -l) -ne 0 ]]
then
    echo "Duplicated string(s) found"
    exit 1
else
    echo "No duplicated strings found"
    exit 0
fi
