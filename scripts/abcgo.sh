threshold=63

BLUE=$(tput setaf 4)
RED_BG=$(tput setab 1)
GREEN_BG=$(tput setab 2)
NC=$(tput sgr0) # No Color

VERBOSE=false

if [[ $* == *verbose* ]]; then
    VERBOSE=true
fi

if ! [ -x "$(command -v abcgo)" ]
then
    echo -e "${BLUE}Installing abcgo${NC}"
    GO111MODULE=off go get -u github.com/droptheplot/abcgo
fi

if [ "$VERBOSE" = true ]; then
    echo -e "${BLUE}All ABC metrics${NC}:"
    abcgo -path .
    echo -e "${BLUE}Functions with ABC metrics greater than ${threshold}${NC}:"
fi

if [[ $(abcgo -path . -sort -format raw | awk "\$4>${threshold}" | tee /dev/tty | wc -l) -ne 0 ]]
then
    echo -e "${RED_BG}[FAIL]${NC} Functions with too high ABC metrics detected!"
    exit 1
else
    echo -e "${GREEN_BG}[OK]${NC} ABC metrics are ok for all functions in all packages"
    exit 0
fi

