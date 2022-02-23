function run_unit_tests() {
    # shellcheck disable=SC2046
    if ! go test -coverprofile coverage.out $(go list ./... | grep -v tests | tr '\n' ' ')
    then
        echo "unit tests failed"
        exit 1
    fi
}

run_unit_tests
