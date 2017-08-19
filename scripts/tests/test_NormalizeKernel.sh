#! /bin/bash
set -u 		# treat unset variables as an error

PROGRAM_DIR="$( cd "${BASH_SOURCE[0]%/*}" && pwd )"
readonly PROGRAM_DIR

testNormalizeKernelEqualTo() {

	local -i i=1
	local kernelversion

	while read -ra _test
	do
		#printf "test[$i]: <%s> <%s>\n" "${_test[0]}" "${_test[1]}"
		lib_func_normalize_kernel "${_test[0]}"
		kernelversion="${lib_func_normalize_kernel_return}"

		#printf "test[$i]: <%s> <%s>\n" "${kernelversion}" "${_test[1]}"
		assertEquals "EqualTo failure test#$(( i++ ))" "${_test[1]}" "${kernelversion}"
		
	done <<- EOF
	3.0.101-0.47.71.7930.0.PTF-default		3.0.101-0.47.71.7930.0.1
	3.0.101-0.47.71-default           		3.0.101-0.47.71-1
	3.0.101-0.47-bigsmp          			3.0.101-0.47-1
	3.0.101-88-bigmem						3.0.101-88-1
	3.0.101-71-ppc64						3.0.101-71-1
	2.6.32-504.16.2.el6.x86_64				2.6.32-504.16.2				# Remove trailing ".el6.x86_64"
	3.10.0-327.46.1.el7.x86_64				3.10.0-327.46.1
	3.10.0-514.26.2.el7.x86_64				3.10.0-514.26.2
	EOF
}

testNormalizeKernelShouldFail() {

	local kernelversion

	#The following tests should fail (test the tester)
	lib_func_normalize_kernel '3.0.101-0.47.71-default2'
	kernelversion="${lib_func_normalize_kernel_return}"
	assertNotEquals 'test[1]: testing the tester failed' '3.0.101-0.47.71.1' "${kernelversion}"
}

# oneTimeSetUp () {

# }
# oneTimeTearDown
# setUp
# tearDown

#Import Libraries 
# - order is important - sourcing shunit triggers testing
# - thats also the reason, why it could not be done during oneTimeSetup
source "${PROGRAM_DIR}/../bin/saphana-logger"
source "${PROGRAM_DIR}/../bin/saphana-helper-funcs"
source "${PROGRAM_DIR}/shunit"
