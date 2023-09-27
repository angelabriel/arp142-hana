#!/usr/bin/env bash
set -u  # treat unset variables as an error

PROGRAM_DIR="$( cd "${BASH_SOURCE[0]%/*}" && pwd )"
readonly PROGRAM_DIR

#fake PREREQUISITE functions

test_kernel-tainted_set0-untainted_ok() {

    #arrange
    path_to_kernel_tainted="${PROGRAM_DIR}/mock_kernel_tainted"
    echo 0 > "${path_to_kernel_tainted}"

    #act
    check_0090_os_kernel_tainted

    #assert
    assertEquals "CheckOk? RC" '0' "$?"
}



test_kernel-tainted_set1-tainted_error() {

    #arrange
    path_to_kernel_tainted="${PROGRAM_DIR}/mock_kernel_tainted"
    echo 1 > "${path_to_kernel_tainted}"

    #act
    check_0090_os_kernel_tainted

    #assert
    assertEquals "CheckError? RC" '2' "$?"
}


oneTimeSetUp() {

    #shellcheck source=../saphana-logger-stubs
    source "${PROGRAM_DIR}/../saphana-logger-stubs"

    #shellcheck source=../../lib/check/0090_os_kernel_tainted.check
    source "${PROGRAM_DIR}/../../lib/check/0090_os_kernel_tainted.check"

}

oneTimeTearDown() {
    rm -f "${PROGRAM_DIR}/mock_kernel_tainted"
}

setUp() {

    echo 0 > "${PROGRAM_DIR}/mock_kernel_tainted"

}

#tearDown

#Import Libraries
# - order is important - sourcing shunit triggers testing
# - that's also the reason, why it could not be done during oneTimeSetup

#Load and run shUnit2
#shellcheck source=../shunit2
source "${PROGRAM_DIR}/../shunit2"
