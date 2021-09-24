#!/bin/bash
set -u
#
# file: https://galaxy.southbridge.io/templates/antools/-/blob/master/scripts/hooklog.sh
# version: 0.1.0
#
# Use this script with Helm pre-rollback hook for logs and events printing.
#
# Nikolay Mesropyan and Southbridge LLC team, 2020 A.D.
#

_main() {
    local fn=${FUNCNAME[0]}

    trap '_except $LINENO' ERR

    if [[ "${1:-NOP}" != NOP ]]; then
	local ns="$1"
    else
	_help; exit 0
    fi

    if [[ "${2:-NOP}" != NOP ]]; then
	local release="$2"
    else
	_help; exit 0
    fi

    printf '\033[1;31m%s\033[1;35m' "Get pods status: "
    printf -- '-%.0s' {1..130}
    printf '\033[0m\n'
    kubectl -n "$ns" get po -lrelease="$release" -o wide | grep -Fv atomiclog

    printf '\033[1;31m%s\033[1;35m' "Tail of overall 'Warning' events: "
    printf -- '-%.0s' {1..108}
    printf '\033[0m\n'
    kubectl -n "$ns" get events --field-selector type=Warning --sort-by='.metadata.creationTimestamp' | tail

    local -a Daemonsets=() Deployments=() Jobs=() Statefulsets=()

    mapfile -t Daemonsets < <( kubectl -n "$ns" get daemonset -lrelease="$release" --no-headers -o custom-columns=":metadata.name" )
    mapfile -t Deployments < <( kubectl -n "$ns" get deployment -lrelease="$release" --no-headers -o custom-columns=":metadata.name" )
    mapfile -t Jobs < <( kubectl -n "$ns" get job -lrelease="$release" --no-headers -o custom-columns=":metadata.name" )
    mapfile -t Statefulsets < <( kubectl -n "$ns" get statefulset -lrelease="$release" --no-headers -o custom-columns=":metadata.name" )

    for (( i = 0; i < ${#Daemonsets[@]}; i++ )); do
	__not_ready DaemonSet "${Daemonsets[i]}"
    done

    for (( i = 0; i < ${#Deployments[@]}; i++ )); do
	__not_ready Deployment "${Deployments[i]}"
    done

    for (( i = 0; i < ${#Jobs[@]}; i++ )); do
	__not_ready Job "${Jobs[i]}"
    done

    for (( i = 0; i < ${#Statefulsets[@]}; i++ )); do
	__not_ready StatefulSet "${Statefulsets[i]}"
    done

    exit 0
}

__not_ready() {
    local not_ready_pod=""
    local text="of the first not-ready pod"

    not_ready_pod=$(kubectl -n "$ns" get po -lrelease="$release" --no-headers | grep "^$2" \
	| gawk -F' *|/' '$4 !~ "Completed|Evicted" { print $0 }' \
	| gawk -F' *|/' '$2 != $3 || $4 != "Running" { print $1; exit }')

    if [[ -n "$not_ready_pod" ]]; then
	__events "$@"
	__logs "$@"
    fi
}

__events() {
    printf '\033[1;31m%s\033[1;35m' "$1 ${2}: events ${text}: "
    printf -- '-%.0s' {1..76}
    printf '\033[0m\n'
    kubectl -n "$ns" get events --field-selector involvedObject.name="$not_ready_pod" || :
}

__logs() {
    local -a Containers=()

    mapfile -t Containers < <( kubectl -n "$ns" get po "$not_ready_pod" --no-headers -o jsonpath="{.spec.containers[*].name}" | sed 's/\s\+/\n/g' )

    for (( i = 0; i < ${#Containers[@]}; i++ )); do
	printf '\033[1;31m%s\033[1;35m' "$1 ${2}: logs ${text}, container '${Containers[i]}': "
	printf -- '-%.0s' {1..56}
	printf '\033[0m\n'
	kubectl -n "$ns" logs "$not_ready_pod" "${Containers[i]}" --ignore-errors=true --tail=-1 || :
    done
}

_except() {
    local ret=$?
    local no=${1:-no_line}

    echo "error occured in function '$fn' near line ${no}, exit code ${ret}. Continuing..."
}

_help() {
    echo "Usage: $0 <metadata.namespace> <metadata.labels.release>" >&2
}

_main "$@"

