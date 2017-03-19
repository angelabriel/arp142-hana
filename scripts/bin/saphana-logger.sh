#!/bin/bash
umask 022

#------------------------------------------------------------------
# SAP HANA Logger
#------------------------------------------------------------------
# (C) Copyright SAP 2017
#
# Library Functions
# Script name: "saphana-logger.sh"
#------------------------------------------------------------------
# return if saphana-logger already loaded
[[ -n "${HANA_LOGGER_VERSION:-}" ]] && return 0

HANA_LOGGER_VERSION='0.0.1'

#exec 3>&2 # logging stream (file descriptor 3) defaults to STDERR

logNotify() {		logger 0 "[N]"	"$1"; } # Always prints
logCritical() {		logger 1 "[C]"	"$1"; }
logError() {		logger 2 "[E]"	"$1"; }
logWarn() {			logger 3 "[W]"	"$1"; }
logInfo() {			logger 4 "[I]"	"$1"; }
logDebug() {		logger 5 "[D]"	"$1"; }
logTrace() {		logger 6 "[T]"	"$1"; }

logger() {
	if [[ ${LOG_VERBOSE_LVL} -ge "$1" ]]; then

		local logLevel="$2"
		shift 2
		
		local -r  datestring=$(date +'%H:%M:%S.%3N')
		local -ir prefix_length=$((13+10))	#len("00:04:32.001")+1 && len("[WARNING]")+1
		local -ri content_width=$((COLUMNS-prefix_length-1))

		# Expand escaped characters, wrap at COLUMNS chars, indent wrapped lines
		#printf "%-24s %s\n" "${datestring} ${logLevel}" "$*" | fold -w ${COLUMNS} | sed '2~1s/^/                        /' #>&3
		if [[ -t 1 ]]; then #FD1 = stdout
		local line
			printf "%s\n" "$*" | fold -w ${content_width} | ( read -r line ; printf "%-${prefix_length}s %s\n" "${datestring} ${logLevel}" "${line}" ; while read -r line ; do printf "%-${prefix_length}s %s\n" " " "${line}" ; done )
		else
			printf "%-${prefix_length}s %s\n" "${datestring} ${logLevel}" "$*"
		fi
	fi
}

print_folded() {
	local status="$1"
	shift 1

	local -r  datestring=$(date +'%H:%M:%S.%3N')
	local -ir prefix_length=$((13+10))	#len("00:04:32.001")+1 && len("[WARNING]")+1
	local -ri content_width=$((COLUMNS-prefix_length-1))

	if [[ -t 1 ]]; then #FD1 = stdout
		local line
		printf "%s\n" "$*" | fold -w ${content_width} | ( read -r line ; printf "%-${prefix_length}s %s\n" "${datestring} ${status}" "${line}" ; while read -r line ; do printf "%-${prefix_length}s %s\n" " " "${line}" ; done )
	else
		printf "%-${prefix_length}s %s\n" "${datestring} ${status}" "$*"
	fi
}

#ToDo: remove/revise use_colored_output stuff
use_colored_output() {
	return 1
}

logCheckError() {
	if use_colored_output; then
		print_folded "${warn}[ERROR]${norm}"	"$@"
	else
		print_folded  "[ERROR]"	"$@"
	fi
}

logCheckWarning() {
	if use_colored_output; then
		print_folded "${attn}${blb}[WARNING]${norm}"	"$@"
	else
		print_folded "[WARNING]"	"$@"
	fi
}

logCheckOk() {
	if [[ ${LOG_VERBOSE_LVL} -ge 4 ]]; then
		if use_colored_output; then
			print_folded "${done}[OK]${norm}"	"$@"
		else
			print_folded "[OK]"	"$@"
		fi
	fi
}

logCheckInfo() {
	if [[ ${LOG_VERBOSE_LVL} -ge 4 ]]; then
		print_folded  "[INFO]"	"$@"
	fi
}

logCheckSkipped() {
	if [[ ${LOG_VERBOSE_LVL} -ge 4 ]]; then
		print_folded  "[SKIPPED]"	"$@"
	fi
}


#============================================================
# LIB MAIN - initialization
#============================================================
_lib_logger_main() {

	COLUMNS=80 # required before 1st logger usage

	logTrace "<${BASH_SOURCE[0]}:${FUNCNAME[*]}>"

	# ToDo: -t 1 stdout? 
	#  if [[ -t 1 && -n "$TERM" && "$TERM" != "dumb" ]]; then
    if [[ -n "$TERM" && "$TERM" != "dumb" ]]; then
        COLUMNS=$(tput cols)		
    fi

}

# Variables to be used by other 
declare -i LOG_VERBOSE_LVL=3 # #notify/silent=0 (always), critical=1, error=2, warn=3 (default), info=4, debug=5, trace=6

# ToDo: declare -ix ?? - logging should also work for pipes (grep or less)
declare -i COLUMNS
_lib_logger_main