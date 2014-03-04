# vim: tw=0:ts=4:sw=4:et:ft=bash

:<<[core:docstring]
SSH Tunnelling
[core:docstring]

#. Tunneling Module -={
core:import dns
core:import net
core:import util

core:requires ssh
core:requires netstat

declare -rg g_CP_PREFIX="${SITE_USER_RUN?}/ssh-sm"

#. tunnel:status -={
function :tunnel:pid() {
    local -i e=${CODE_FAILURE?}

    local -r qdn="${1}"
    local -r controlpath=${g_CP_PREFIX?}@${qdn}
    if [ -e "${controlpath}" ]; then
        local raw
        raw=$(
            ssh -qo 'ControlMaster=no' -S "${controlpath}" ${qdn} -O check 2>&1 |
                tr -d '\r\n'
        )
        e=$?

        if [ $e -eq 0 ]; then
            echo "${raw}" |
                sed -e 's/Master running (pid=\(.*\))$/\1/'
        fi
    else
        e=${CODE_SUCCESS?} #. No tunnel
    fi

    return $e
}
function :tunnel:list() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 1 ]; then
        local -i pid=$1
        netstat -ntlp 2>/dev/null|
            awk '$1~/^tcp$/&&$7~/^'${pid}'.ssh$/{print$4}' |
            awk -F: '{print$2}'
        e=$?
    fi

    return $e
}
function tunnel:status() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -eq 1 ]; then
        local -r qdn=${1}
        cpf "Checking ssh control master to %{@host:${qdn}}..."

        local portstr

        local pid
        pid=$(:tunnel:pid ${qdn})
        e=$?

        if [ $e -eq ${CODE_SUCCESS?} ]; then
            local -a ports
            ports=( $(:tunnel:list ${pid} ) )
            portstr=$(:util:join , ports)
        fi

        theme HAS_AUTOED $e "${pid:-NO_TUNNEL}:${portstr:-NO_PORTS}"
    elif [ $# -eq 0 ]; then
        for socket in ${g_CP_PREFIX?}*; do
            tunnel:status ${socket##*@}
        done
        e=${CODE_SUCCESS?}
    fi

    return $e
}
#. }=-
#. tunnel:start -={
#. XXX do not $(:tunnel:start) - it hangs !?!?!
function :tunnel:start() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 1 ]; then
        local -i pid
        local -r qdn=${1}
        local -r controlpath=${g_CP_PREFIX?}@${qdn}
        if [ -S "${controlpath}" ]; then
            pid=$(:tunnel:pid ${qdn})
            [ $? -ne ${CODE_SUCCESS?} ] || e=${CODE_E01?}
        else
            if ssh -qno 'ControlMaster=yes' -fNS "${controlpath}" ${qdn}; then
                pid=$(:tunnel:pid ${qdn})
                e=$?
            fi
        fi
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function tunnel:start:usage() { echo "<qdn>"; }
function tunnel:start() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -eq 1 ]; then
        local -r qdn=${1}
        cpf "Starting ssh control master to %{@host:${qdn}}..."
        local -i pid
        local -r controlpath=${g_CP_PREFIX?}@${qdn}
        if [ -S "${controlpath}" ]; then
            pid=$(:tunnel:pid ${qdn})
            e=${CODE_SUCCESS?}
            theme HAS_WARNED "ALREADY_RUNNING:${pid}"
        else
            if :tunnel:start ${qdn}; then
                pid=$(:tunnel:pid ${qdn})
                e=$?
            fi
            theme HAS_AUTOED $e ${pid}
        fi
    fi

    return $e
}
#. }=-
#. tunnel:stop -={
function :tunnel:stop() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 1 ]; then
        local -i pid=0
        local -r qdn="${1}"
        local -r controlpath=${g_CP_PREFIX?}@${qdn}
        if [ -e "${controlpath}" ]; then
            pid=$(:tunnel:pid ${qdn})
            if [ $? -eq ${CODE_SUCCESS?} ]; then
                ssh -qno 'ControlMaster=no'\
                    -fNS "${controlpath}" ${qdn} -O stop >/dev/null 2>&1
                e=$?
            fi
        else
            e=${CODE_FAILURE?}
        fi
        echo ${pid}
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function tunnel:stop:usage() { echo "<qdn>"; }
function tunnel:stop() {
    local -i e=${CODE_DEFAULT?}

    if [ $# -eq 1 ]; then
        local -r qdn="${1}"
        cpf "Stopping ssh control master to %{@host:${qdn}}..."

        local -r controlpath=${g_CP_PREFIX?}@${qdn}
        if [ -e "${controlpath}" ]; then
            local -i pid
            pid=$(:tunnel:stop "${qdn}")
            e=$?
            theme HAS_AUTOED $e ${pid}
        else
            e=${CODE_SUCCESS?}
            theme HAS_WARNED "NOT_RUNNING"
        fi
    fi

    return $e
}
#. }=-
#. tunnel:create -={
function :tunnel:create() {
    local -i e=${CODE_FAILURE?}

    if [ $# -eq 5 ]; then
        local qdn="${1}"
        local laddr="${2}"
        local lport="${3}"
        local raddr="${4}"
        local rport="${5}"
        local -r controlpath=${g_CP_PREFIX?}@${qdn}
        if [ -S ${controlpath} ]; then
            if ! :net:localportping ${lport}; then
                ssh -qo 'ControlMaster=no' -O forward -S "${controlpath}"\
                    -fNL "${laddr}:${lport}:${raddr}:${rport}" ${qdn}
                e=$?
            else
                e=${CODE_E01?}
            fi
        else
            e=${CODE_E02?}
        fi
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function tunnel:create:shflags() {
    cat <<!
string local  localhost "local-addr"  l
string remote localhost "remote-addr" r
!
}
function tunnel:create:usage() { echo "<qdn> <local-port> <remote-port>"; }
function tunnel:create() {
    local -i e=${CODE_DEFAULT?}

    local raddr=${FLAGS_remote:-localhost}; unset FLAGS_remote
    local laddr=${FLAGS_local:-localhost};  unset FLAGS_local

    if [ $# -eq 3 ]; then
        local -r qdn=${1}
        local -i lport=${2}
        local -i rport=${3}
        local pid
        pid=$(:tunnel:pid ${qdn})
        e=$?
        if [ $e -eq ${CODE_SUCCESS?} -a ${#pid} -eq 0 ]; then
            if :tunnel:start ${qdn}; then
                pid=$(:tunnel:pid ${qdn})
            fi
        fi

        cpf "Creating ssh tunnel %{@host:${qdn}} ["
        e=$?
        if [ ${e} -eq ${CODE_SUCCESS?} -a ${#pid} -gt 0 ]; then
            cpf "%{@ip:${laddr?}}:%{@int:${lport}}"
            cpf "%{r:<--->}"
            cpf "%{@ip:${raddr?}}:%{@int:${rport}}"
            cpf "] ..."
            :tunnel:create ${qdn} ${laddr} ${lport} ${raddr} ${rport}
            e=$?
            if [ $e -ne ${CODE_E01?} ]; then
                theme HAS_AUTOED $e
            else
                theme HAS_FAILED "${lport}:PORT_USED"
            fi
        else
            theme HAS_FAILED
        fi
    fi

    return $e
}
#. }=-
#. }=-
