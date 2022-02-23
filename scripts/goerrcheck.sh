if ! [ -x "$(command -v errcheck)" ]
then
    echo -e "${BLUE}Installing errcheck ${NC}"
    GO111MODULE=off go get github.com/kisielk/errcheck
fi

errcheck ./...
