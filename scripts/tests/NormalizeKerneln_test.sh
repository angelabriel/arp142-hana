#!/usr/bin/env bash
set -u # treat unset variables as an error

PROGRAM_DIR="$(cd "${BASH_SOURCE[0]%/*}" && pwd)"
readonly PROGRAM_DIR

testNormalizeKernelEqualTo() {

    local -i i=1
    local kut

    while read -ra _test; do
        #printf "test[$i]: orig <%s> <%s>\n" "${_test[1]}" "${_test[0]}"
        kut="${_test[0]}"
        LIB_FUNC_NORMALIZE_KERNELn kut

        #printf "test[$i]: norm <%s> <%s>\n"  "${_test[1]}" "${kut}"
        assertEquals "EqualTo failure test#$((i++))" "${_test[1]}" "${kut}"

    done <<-EOF
    3.0.101-0.47.71.7930.0.PTF-default      3.0.101-0.47.71.7930.0.1
    3.0.101-0.47.71-default                 3.0.101-0.47.71-1
    3.0.101-0.47-bigsmp                     3.0.101-0.47-1
    3.0.101-88-bigmem                       3.0.101-88-1
    3.0.101-71-ppc64                        3.0.101-71-1
    2.6.32-504.16.2.el6.x86_64              2.6.32-504.16.2             # Remove trailing ".el6.x86_64"
    3.10.0-327.46.1.el7.x86_64              3.10.0-327.46.1
    3.10.0-514.26.2.el7.x86_64              3.10.0-514.26.2
	EOF
}

testNormalizeKernelShouldFail() {

    local kut

    #The following tests should fail (test the tester)
    kut='3.0.101-0.47.71-default2'
    LIB_FUNC_NORMALIZE_KERNELn kut

    #printf "test[1]: norm <%s> <%s>\n"  '3.0.101-0.47.71-default2' "${kut}"
    assertNotEquals 'test[1]: testing the tester failed' '3.0.101-0.47.71.1' "${kut}"
}

oneTimeSetUp() {

    # prevent loading of original libraries
    # shellcheck disable=SC2034
    LIB_LINUX_RELEASE='dont load'
    # shellcheck disable=SC2034
    LIB_PLATF_x86_64_RELEASE='dont load'
    # shellcheck disable=SC2034
    LIB_PLATF_POWER_RELEASE='dont load'

    declare -i LIB_PLATF_RAM_MIB_PHYS=1024
    declare -i LIB_PLATF_RAM_MiB_AVAILABLE=1024
    declare -i LIB_PLATF_RAM_KiB_AVAILABLE=1024

    #shellcheck source=./saphana-logger-stubs
    source "${PROGRAM_DIR}/./saphana-logger-stubs"

    #shellcheck source=../bin/saphana-helper-funcs
    source "${PROGRAM_DIR}/../bin/saphana-helper-funcs"

}

# oneTimeTearDown
# setUp
# tearDown

#Import Libraries
# - order is important - sourcing shunit triggers testing
# - that's also the reason, why it could not be done during oneTimeSetup

#shellcheck source=./shunit2
source "${PROGRAM_DIR}/shunit2"
