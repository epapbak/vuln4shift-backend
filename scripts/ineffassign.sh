BLUE=$(tput setaf 4)
RED_BG=$(tput setab 1)
GREEN_BG=$(tput setab 2)
NC=$(tput sgr0) # No Color

echo -e "${BLUE}Detecting ineffectual assignments in Go code${NC}"

if ! [ -x "$(command -v ineffassign)" ]
then
    echo -e "${BLUE}Installing ineffassign${NC}"
    GO111MODULE=off go get github.com/gordonklaus/ineffassign
fi

if ! ineffassign ./...
then
    echo -e "${RED_BG}[FAIL]${NC} Code with ineffectual assignments detected"
    exit 1
else
    echo -e "${GREEN_BG}[OK]${NC} No ineffectual assignments has been detected"
    exit 0
fi
