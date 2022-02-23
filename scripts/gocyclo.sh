if ! [ -x "$(command -v gocyclo)" ]
then
    echo -e "${BLUE}Installing gocyclo${NC}"
    GO111MODULE=off go get github.com/fzipp/gocyclo/cmd/gocyclo
fi

gocyclo -over 9 -avg .
