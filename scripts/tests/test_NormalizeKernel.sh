#! /bin/bash

PROGRAM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly PROGRAM_DIR

testNormalizeKernelEqualTo() {

	local -i i=1
	local kernelversion

	while read -ra _test
	do
		#printf "test[$i]: <%s> <%s>\n" "${_test[0]}" "${_test[1]}"
		kernelversion=$(lib_func_normalize_kernel "${_test[0]}")

		#printf "test[$i]: <%s> <%s>\n" "${kernelversion}" "${_test[1]}"
		assertEquals "EqualTo failure test#$(( i++ ))" "${kernelversion}" "${_test[1]}"
		
	done <<- EOF
	3.0.101-0.47.71.7930.0.PTF-default		3.0.101-0.47.71.7930.0.1
	3.0.101-0.47.71-default           		3.0.101-0.47.71-1
	3.0.101-0.47-bigsmp          			3.0.101-0.47-1
	3.0.101-88-bigmem						3.0.101-88-1
	3.0.101-71-ppc64						3.0.101-71-1
	2.6.32-504.16.2.el6.x86_64				2.6.32-504.16.2				# Remove trailing ".el6.x86_64"
	EOF
}

testNormalizeKernelShouldFail() {

	local kernelversion

	#The following tests should fail (test the tester)
	kernelversion=$(lib_func_normalize_kernel '3.0.101-0.47.71-default2')
	assertNotEquals 'test[1]: testing the tester failed' "${kernelversion}" '3.0.101-0.47.71.1'
}

oneTimeSetUp () {
	#Import Libraries
	source "${PROGRAM_DIR}/../bin/saphana-logger"
	source "${PROGRAM_DIR}/../bin/saphana-helper-funcs"
}
# oneTimeTearDown
# setUp
# tearDown

# load shunit2
source "${PROGRAM_DIR}/shunit"
