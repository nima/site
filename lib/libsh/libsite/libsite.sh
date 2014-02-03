# vim: tw=0:ts=4:sw=4:et:ft=bash
#. Site Engine -={
#. 1.1  Date/Time and Basics -={
export NOW=$(date --utc +%s)
#. FIXME: Mac OS X needs this instead:
#. FIXME: export NOW=$(date -u +%s)

export PS4=":\${BASH_SOURCE//\${SITE_USER}/}:\${LINENO} -> "
#. }=-
#. 1.2  Paths -={
: ${SITE_PROFILE?}
export SITE_SITE_BASENAME=$(basename $0)

export SITE_SCM=$(readlink ~/.site/.scm)

export SITE_CORE=$(dirname $(dirname $(readlink ~/bin/site)))
export SITE_CORE_MOD=${SITE_CORE}/module
export SITE_CORE_LIBEXEC=${SITE_CORE}/libexec
export SITE_CORE_BIN=${SITE_CORE}/bin
export SITE_CORE_LIB=${SITE_CORE}/lib
export SITE_CORE_LIBPY=${SITE_CORE}/lib/libpy
export SITE_CORE_LIBJS=${SITE_CORE}/lib/libjs
export SITE_CORE_LIBSH=${SITE_CORE}/lib/libsh
export SITE_CORE_EXTERN=${SITE_CORE}/extern
export SITE_CORE_EXTERN_LIBSH=${SITE_CORE_EXTERN}/lib/libsh
export SITE_CORE_EXTERN_LIBPY=${SITE_CORE_EXTERN}/lib/libpy
export SITE_CORE_EXTERN_LIBRB=${SITE_CORE_EXTERN}/lib/librb
export SITE_CORE_EXTERN_LIBEXEC=${SITE_CORE_EXTERN}/libexec
export SITE_UNIT_STATIC=${SITE_CORE_LIBSH}/libsite/unit/static.sh
export SITE_UNIT_DYNAMIC=${SITE_CORE_LIBSH}/libsite/unit/dynamic.csv

export SITE_USER=${HOME}/.site
export SITE_USER_VAR=${SITE_USER}/var
export SITE_USER_RUN=${SITE_USER}/var/run
export SITE_USER_CACHE=${SITE_USER}/var/cache/
export SITE_USER_ETC=${SITE_USER}/etc
export SITE_USER_LOG=${SITE_USER}/var/log/site.log
export SITE_USER_TMP=${SITE_USER}/var/tmp
export SITE_USER_MOD=${SITE_USER}/module
export SITE_USER_LIBEXEC=${SITE_USER}/libexec
export SITE_USER_EXTERN=${SITE_USER}/extern
export SITE_USER_EXTERN_LIBEXEC=:${SITE_USER_EXTERN}/libexec

export PATH+=:${SITE_CORE_LIBEXEC}
export PATH+=:${SITE_USER_LIBEXEC}
export PATH+=:${SITE_CORE_EXTERN_LIBEXEC}
export PATH+=:${SITE_USER_EXTERN_LIBEXEC}

export PYTHONPATH+=:${SITE_CORE_LIBPY}
export PYTHONPATH+=:${SITE_CORE_EXTERN_LIBPY}
export PYTHONPATH+=:${SITE_CORE_EXTERN_LIBPY}/pyobjpath
#. }=-
#. 1.3  User/Profile Configuration -={
declare -A USER_MODULES
export USER_MODULES

declare -g -A CORE_MODULES=(
    [help]=1
    [tutorial]=1
    [softlayer]=1
    [hgd]=1
    [remote]=1
    [git]=1
    [ng]=1
    [dns]=1
    [net]=1
    [ldap]=1
    [unit]=1
    [mongo]=1
    [util]=1
    [gpg]=1
    [vault]=1
)

source ${SITE_USER_ETC}/site.conf
test ! -f ~/.siterc || source ~/.siterc
: ${USER_TLDS[@]?}
: ${USER_FULLNAME?}
: ${USER_USERNAME?}
: ${USER_EMAIL?}

#. GLOBAL_OPTS 1/4:
declare -i g_HELP=0
declare -i g_VERBOSE=0
declare -i g_LDAPHOST=-1
declare -i g_CACHED=0
declare g_FORMAT=ansi
declare g_DUMP

declare g_TLDID=${USER_TLDID_DEFAULT:-.}
#. }=-
#. 1.4  Core Configuration -={
unset  CDPATH
export SITE_DEADMAN=${SITE_USER_CACHE}/deadman
export SITE_IN_COLOR=1
source ${SITE_CORE_MOD?}/cpf
#. }=-
#. 1.5  ShUnit2 -={
export SHUNIT2=$(which shunit2)
#. }=-
#. 1.6  ShFlags -={
export SHFLAGS=${SITE_CORE_EXTERN_LIBSH}/shflags
source ${SHFLAGS?}
#. }=-
#. 1.7  Error Code Constants -={
true
TRUE=$?
CODE_SUCCESS=${TRUE?}

false
FALSE=$?
CODE_FAILURE=${FALSE?}

CODE_E01=128               #. 128..255   Errors
CODE_E02=129
CODE_E03=130
CODE_E04=131
CODE_E05=132
CODE_E06=133
CODE_E07=134
CODE_E08=135
CODE_E09=136

CODE_USER_MAX=63           #. 64..127 Internal
CODE_DISABLED=64
CODE_USAGE_SHORT=90
CODE_USAGE_MODS=91
CODE_USAGE_MOD=92
CODE_USAGE_FN_GUESS=93
CODE_USAGE_FN_SHORT=94
CODE_USAGE_FN_LONG=95

CODE_IMPORT_GOOOD=0 #. good module
CODE_IMPORT_ADMIN=1 #. administratively disabled
CODE_IMPORT_ERROR=2 #. invalid/bad module (can't source/parse)
CODE_IMPORT_UNDEF=3 #. no such module
CODE_IMPORT_UNSET=4 #. no module set

export SITE_DELIM=$(printf "\x07")

CODE_DEFAULT=${CODE_USAGE_FN_LONG?}
#. }=-
#. 1.8  Logging -={
declare -A SITE_LOG_NAMES=(
    [EMERG]=0 [ALERT]=1 [CRIT]=2 [ERR]=3
    [WARNING]=4 [NOTICE]=5 [INFO]=6 [DEBUG]=7
)
declare -A SITE_LOG_CODES=(
    [0]=EMERG [1]=ALERT [2]=CRIT [3]=ERR
    [4]=WARNING [5]=NOTICE [6]=INFO [7]=DEBUG
)
function core:log() {
    local code=${1}
    local -i level=0
    case ${code} in
        EMERG|ALERT|CRIT|ERR|WARNING|NOTICE|INFO|DEBUG)
            level=${SITE_LOG_NAMES[${code}]}
        ;;
    esac

    if [ ${#module} -gt 0 ]; then
        caller=${module}
        [ ${#fn} -eq 0 ] || caller+=":${fn}"
    else
        local -i fi=0
        while true; do
            case ${FUNCNAME[${fi}]} in
                source|core:*|:core:*|::core:*) let fi++;;
                *) break;;
            esac
        done
        local caller=${FUNCNAME[${fi}]}
    fi

    if [ ${SITE_LOG_NAMES[${USER_LOG_LEVEL}]} -ge ${level} ]; then
        shift 1
        declare ts=$(date +"${SITE_DATE_FORMAT}")

        declare msg=$(printf "%s; %5d; %8s[%24s];" "${ts}" "${$--1}" "${code}" "${caller}")
        [ -e ${SITE_USER_LOG} ] || touch ${SITE_USER_LOG}
        if [ -f ${SITE_USER_LOG} ]; then
            chmod 600 ${SITE_USER_LOG}
            echo "${msg} $@" >> ${SITE_USER_LOG}
        fi
        #printf "%s; %5d; %8s[%24s]; $@\n" "${ts}" "$$" "${code}" "$(sed -e 's/ /<-/g' <<< ${FUNCNAME[@]})" >> ${WMII_LOG}
    fi
}
#. }=-
#. 1.9  Modules -={
declare -A g_SITE_IMPORTED_EXIT

function core:softimport() {
    #. 0: good module
    #. 1: administratively disabled
    #. 2: invalid/bad module (can't source/parse)
    #. 3: no such module defined
    #. 4: no module set
    local -i e=9

    if [ $# -eq 1 ]; then
        local module=$1
        if [ -z "${g_SITE_IMPORTED_EXIT[${module}]}" ]; then
            if [ ${USER_MODULES[${module}]-9} -eq 1 ]; then
                if [ -f ${SITE_USER_MOD}/${module} ]; then
                    if ( source ${SITE_USER_MOD}/${module} >/tmp/site.ouch 2>&1 ); then
                        source ${SITE_USER_MOD}/${module}
                        rm -f /tmp/site.ouch
                        e=${CODE_IMPORT_GOOOD?}
                    else
                        e=${CODE_IMPORT_ERROR?}
                    fi
                else
                    e=${CODE_IMPORT_UNDEF?}
                fi
            elif [ ${CORE_MODULES[${module}]-9} -eq 1 ]; then
                if [ -f ${SITE_CORE_MOD}/${module} ]; then
                    if ( source ${SITE_CORE_MOD}/${module} >/tmp/site.ouch 2>&1 ); then
                        source ${SITE_CORE_MOD}/${module}
                        rm -f /tmp/site.ouch
                        e=${CODE_IMPORT_GOOOD?}
                    else
                        e=${CODE_IMPORT_ERROR?}
                    fi
                else
                    e=${CODE_IMPORT_UNDEF?}
                fi
            elif [ ${CORE_MODULES[${module}]-9} -eq 0 -o ${USER_MODULES[${module}]-9} -eq 0 ]; then
                #. Implicitly disabled
                e=1
            elif [ "${module}" == "-" ]; then
                e=${CODE_IMPORT_UNSET?}
            else
                e=${CODE_IMPORT_UNDEF?}
            fi
            g_SITE_IMPORTED_EXIT[${module}]=${e}
        else
            #. Import already attempted, reuse that result
            e=${g_SITE_IMPORTED_EXIT[${module}]}
        fi
    fi

    return $e
}

function core:import() {
    core:softimport $@
    local -i e=$?
    #. Don't raise an exception; that will break softimport too
    [ $e -eq ${CODE_SUCCESS} ] || exit 99 #core:raise EXCEPTION_BAD_MODULE

    return $e
}

function core:imported() {
    local -i e=${CODE_FAILURE}

    if [ $# -eq 1 ]; then
        local module=${1}
        e=${g_SITE_IMPORTED_EXIT[${module}]}
        [ ${#e} -gt 0 ] || e=-1
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return ${e}
}

function core:docstring() {
    local -i e=${CODE_FAILURE}

    if [ $# -eq 1 ]; then
        local module=$1

        e=2 #. No such module
        if [ ${USER_MODULES[${module}]-9} -eq 1 ]; then
            if [ -f ${SITE_USER_MOD}/${module} ]; then
                sed -ne '/^:<<\['${FUNCNAME}'\]/,/\['${FUNCNAME}'\]/{n;p;q}' ${SITE_USER_MOD}/${module}
                e=$?
            fi
        elif [ ${CORE_MODULES[${module}]-9} -eq 1 ]; then
            if [ -f ${SITE_CORE_MOD}/${module} ]; then
                sed -ne '/^:<<\['${FUNCNAME}'\]/,/\['${FUNCNAME}'\]/{n;p;q}' ${SITE_CORE_MOD}/${module}
                e=$?
            fi
        elif [ ${CORE_MODULES[${module}]-9} -eq 0 -o ${USER_MODULES[${module}]-9} -eq 0 ]; then
            e=${CODE_FAILURE} #. Disabled
        fi
        g_SITE_IMPORTED_EXIT[${module}]=$e
    fi

    return $e
}

function :core:requires() {
    local -i e=${CODE_FAILURE}

    if [ $# -eq 1 ]; then
        e=${CODE_SUCCESS}

        if echo "${1}"|grep -q '/'; then
            [ -e "${1}" ] || e=2
        elif ! which "${1}" > /dev/null 2>&1; then
            e=${CODE_FAILURE}
        fi
    fi

    return $e
}

function core:requires() {
    #. Usage examples:
    #.
    #.     core:requires awk
    #.     core:requires PERL LWP::Protocol::https
    local -i e=${CODE_SUCCESS}

    local caller="${FUNCNAME[1]}"
    #. TODO: Check if ${caller} is a valid/plausible executable name
    #local caller_is_mod=$(( ${USER_MODULES[${caller/:*/}]-0} + ${CORE_MODULES[${caller/:*/}]-0} ))
    #if [ ${caller_is_mod} -ne 0 ]; then
    #    core:raise EXCEPTION_MISSING_EXEC $1
    #fi

    local required;
    case $#:${1} in
        1:*)
            if ! :core:requires $1; then
                e=${CODE_FAILURE}
            fi
        ;;
        *:PERL)
            for required in ${@:2}; do
                if ! perl -M${required} -e ';' 2>/dev/null; then
                    core:log NOTICE "${caller} missing required perl module ${required}"
                    e=${CODE_FAILURE}
                fi
            done
        ;;
        *:PYTHON)
            for required in ${@:2}; do
                if ! python -c "import ${required}" 2>/dev/null; then
                    core:log NOTICE "${caller} missing required python module ${required}"
                    e=${CODE_FAILURE}
                fi
            done
        ;;
        *:ENV)
            for required in ${@:2}; do
                if [ -z "${!required}" ]; then
                    core:log NOTICE "${caller} missing required environment variable ${required}"
                    e=${CODE_FAILURE}
                    break
                fi
            done
        ;;
        *:VAULT)
            for required in ${@:2}; do
                if [ ${g_SIDS[${required}]:-0} -ne 1 ]; then
                    core:log NOTICE "${caller} missing required secret ${required}"
                    e=${CODE_FAILURE}
                fi
            done
        ;;
        *:ALL)
            e=${CODE_SUCCESS}
            for required in ${@:2}; do
                if ! :core:requires "${required}"; then
                    e=${CODE_FAILURE}
                    #core:raise EXCEPTION_MISSING_EXEC ${required}
                    break
                fi
            done
        ;;
        *:ANY)
            e=${CODE_FAILURE}
            for required in ${@:2}; do
                if :core:requires "${required}"; then
                    e=${CODE_SUCCESS}
                    break
                fi
            done
            #if [ $e -ne ${CODE_SUCCESS} ]; then
            #    core:raise EXCEPTION_MISSING_EXEC "${@:2}"
            #fi
        ;;
        *) core:raise EXCEPTION_BAD_FN_CALL "${@}";;
    esac

    return $e
    #test $e -eq 0 && return $e || exit $e
}

declare -gA g_SIDS
core:softimport vault
if [ $? -eq ${CODE_IMPORT_GOOOD?} ]; then
    for sid in $(:vault:list ${SITE_USER_ETC}/site.vault); do
        g_SIDS[$sid]=1
    done
fi
#. }=-
#. 1.10 Caching -={
#. 0 means cache forever (default)
#. >0 indeicates TTL in seconds
declare -g g_CACHE_TTL=0

mkdir -p ${SITE_USER_CACHE?}
chmod 3770 ${SITE_USER_CACHE?} 2>/dev/null

#. Keep track if cache was used globally
declare g_CACHE_USED=${SITE_USER_CACHE}/.cache_used
rm -f ${g_CACHE_USED}

CACHE_OUT='eval :core:cached "${*}" && return ${CODE_SUCCESS}'
CACHE_IN='eval :core:cache "${*}"'
CACHE_EXIT='eval return ${PIPESTATUS[0]}'
:<<! USAGE:
Any function (private or internal only, do not try and cache-enable public
functions!) can be cache-enabled simply by insertin two lines; one right at
the start of the function, and one right at the end:

function <module>:<function>() {
  #. vvv 1. Use cache and return or continue
  ${CACHE_OUT}; {

    ...

  } | ${CACHE_IN}; ${CACHE_EXIT}
  #. ^^^ 2. Update cache if previous did not return
}
function :<module>:<function>() { #. Same as above...; }
function ::<module>:<function>() { #. Same as above...; }

Also take note of the indenting of 2 spaces, this makes it non-obstructive, so
you can maintain the usual 4-space indents, and insert these in and out as
you please.

Note that public functions that take local shflags will not allow caching,
and will generate an error.

Finally, the default cache time is g_CACHE_TTL minutes, but this can be
modified for each function by creating the auxiliary function:

function :[:]<module>:<function>:cached() { echo 3600; }

The value echoed will be the replacement TTL.

Don't use this all over the place, only on computationally expensive code
or otherwise slow code (network latency) that is expected to also produce the
same result almost alll the time, for example dns might be a good candidate,
whereas remote code execution is probably a bad candidate.
!

function :core:age() {
    local -i e=${CODE_FAILURE}

    local filename="$1"
    if [ -e ${filename} ]; then
        local -i changed=$(stat -c %Y "${filename}")
        local -i now=$(date +%s)
        local -i elapsed
        let elapsed=now-changed
        echo ${elapsed}
        e=${CODE_SUCCESS}
    fi

    return ${e}
}

function :core:cache:file() {
    local -i e=${CODE_FAILURE}

    local modfn="$1"
    local cachefile
    if [ "$(type -t ${modfn}:cachefile)" == "function" ]; then
        #. File-Cached...
        shift 1
        cachefile=$(${modfn}:cachefile "${@}")
    else
        #. Output-Cached...
        local effective_format=${g_FORMAT}
        if [[ $1 =~ ^: ]] && [ ${g_FORMAT} == "ansi" ]; then
            effective_format=text
        fi

        cachefile=${SITE_USER_CACHE}/${1//:/=}
        cachefile+=+${g_TLDID}
        cachefile+=+${g_VERBOSE}
        cachefile+=+$(echo -ne "${2}"|md5sum|awk '{print$1}')
        cachefile+=.${effective_format}
    fi

    echo "${cachefile}"

    e=${CODE_SUCCESS}
    return $e
}

function :core:cache:age() {
    local -i e=${CODE_FAILURE}

    local cachefile=$(:core:cache:file "${@}")

    :core:age "${cachefile}"
    e=$?

    return $e
}

function ::core:cache:cachetype() {
    local -i e=${CODE_FAILURE}

    if [ $# -eq 1 ]; then
        local cachefile=$1
        local cachetype=file

        if [ "${cachefile:0:1}" == '/' ]; then
            if [ "${cachefile//${SITE_USER_CACHE}/}" != "${cachefile}" ]; then
                cachetype=output
            fi
            e=${CODE_SUCCESS}
        else
            core:raise EXCEPTION_SHOULD_NOT_GET_HERE
        fi
    fi

    echo "${cachetype}"
    return $e
}

function :core:cache() {
    local -i e=${CODE_FAILURE}

    if [ $# -eq 1 ]; then
        local modfn=${FUNCNAME[1]}
        local argv="$1"
        local cachefile=$(:core:cache:file "${modfn}" "${argv}")

        #. If it's a output-cached file..
        case $(::core:cache:cachetype ${cachefile}) in
            output)
                :> ${cachefile}
                chmod 600 ${cachefile}
                while read line; do
                    echo "$line" >> ${cachefile}
                done

                if [ -s ${cachefile} ]; then
                    cat ${cachefile}
                else
                    rm -f ${cachefile}
                fi
            ;;
            file)
                : PASS
            ;;
        esac

        local -i e=${CODE_SUCCESS}
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function :core:cached() {
    #. TTL of 0 means cache forever
    #. TTL > 0 means to cache for TTL seconds
    local -i e=${CODE_FAILURE}

    if [ $# -eq 1 ]; then
        if [ ${g_CACHED} -eq 1 ]; then
            local modfn=${FUNCNAME[1]}
            if [ "$(type -t ${modfn}:shflags)" != "function" ]; then
                local -i ttl=0
                [ "$(type -t ${modfn}:cache)" == "function" ] &&
                    ttl=$(${modfn}:cache) ||
                        ttl=${g_CACHE_TTL}

                local argv="$1"
                local cachefile=$(:core:cache:file "${modfn}" "${argv}")
                local -i age
                age=$(:core:age ${cachefile})
                if [ $? -eq ${CODE_SUCCESS} ]; then
                    if [ ${ttl} -gt 0 -a ${age} -ge ${ttl} ]; then
                        rm -f ${cachefile}
                    else
                        case $(::core:cache:cachetype ${cachefile}) in
                            output)
                                cat ${cachefile}
                                echo ${cachefile} >> ${g_CACHE_USED}
                                e=${CODE_SUCCESS}
                            ;;
                            file)
                                e=${CODE_SUCCESS}
                            ;;
                        esac
                    fi
                fi
            else
                theme ERR "Caching functions that take local shflags not supported." >&2
            fi
        fi
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}
#. }=-
#. 1.11 Execution -={
: ${USER_USERNAME:=$(whoami)}

function ::core:execute:internal() {
    local module=$1
    local fn=$2
    shift 2
    #set -x
    :${module}:${fn} "${@}"
    #set +x
    return $?
}

function ::core:execute:private() {
    local module=$1
    local fn=$2
    shift 2
    #set -x
    ::${module}:${fn} "${@}"
    #set +x
    return $?
}

function ::core:shflags.eval() {
    local -i e=${CODE_FAILURE}

    #. Extract the first 2 non-flag tokens as module and function
    #. All remaining tokens are addred to the new argv array
    local -a argv
    local -i argc=0
    local module=-
    local fn=-

    local arg
    for arg in "${@}"; do
        if [ "${arg:0:1}" != '-' ]; then
            if [ "${module}" == "-" ]; then
                module="${arg?}"
            elif [ "${fn}" == "-" ]; then
                fn="${arg?}"
            else
                argv[${argc}]="${arg?}"
                ((argc++))
            fi
        else
            argv[${argc}]="${arg}"
            ((argc++))
        fi
    done
    set -- "${argv[@]}"

    #. GLOBAL_OPTS 2/4: Our generic and global optiones
    DEFINE_boolean help     false            "<help>"                   H
    DEFINE_boolean verbose  false            "<verbose>"                V
    DEFINE_boolean cached   false            "<use-cache>"              C
    DEFINE_string  format   "${g_FORMAT}"    "ansi|text|csv|html|email" F
    DEFINE_integer ldaphost "${g_LDAPHOST}"  "<ldap-host-index>"        L
    DEFINE_string  tldid    "${g_TLDID}"     "<top-level-domain-id>"    T

    #. Out module/function-specific options
    local -a extra
    if [ ${#module} -gt 0 ]; then
        core:softimport ${module}
        if [ $? -eq ${CODE_IMPORT_GOOOD?} ]; then
            if [ "$(type -t ${module}:${fn}:shflags)" == "function" ]; then
                #. shflags function defined, so let's use it...
                while read f_type f_long f_default f_desc f_short; do
                    DEFINE_${f_type} "${f_long}" "${f_default}" "${f_desc}" "${f_short}"
                    extra+=( FLAGS_${f_long} )
                done < <( ${module}:${fn}:shflags )
            fi
        fi
        cat <<!
declare -g module=${module:-}
declare -g fn=${fn:-}
!
    fi

    #. Process it all
    FLAGS "${@}" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        #. GLOBAL_OPTS 3/4:
        FLAGS_HELP="site ${module} ${fn} [<flags>]"
        #. Booleans get inverted:
        let g_HELP=~${FLAGS_help?}+2; unset FLAGS_help
        let g_VERBOSE=~${FLAGS_verbose?}+2; unset FLAGS_verbose
        let g_CACHED=~${FLAGS_cached?}+2; unset FLAGS_cached
        #. Everything else is straight-forward:
        g_FORMAT=${FLAGS_format?}; unset FLAGS_format
        g_LDAPHOST=${FLAGS_ldaphost?}; unset FLAGS_ldaphost
        g_TLDID=${FLAGS_tldid?}; unset FLAGS_tldid

        if [ ${#g_TLDID} -eq 0 ] || [ ${#USER_IFACE[${g_TLDID}]} -gt 0 ]; then
            cat <<!
#. GLOBAL_OPTS 4/4:
declare g_HELP=${g_HELP?}
declare g_VERBOSE=${g_VERBOSE?}
declare g_FORMAT=${g_FORMAT?}
declare g_LDAPHOST=${g_LDAPHOST?}
declare g_TLDID=${g_TLDID?}
declare g_CACHED=${g_CACHED?}
set -- ${FLAGS_ARGV?}
!
            e=${CODE_SUCCESS}
        fi
    else
        cat <<!
g_DUMP="$(FLAGS "${@}" 2>&1|sed -e '1,2 d' -e 's/^/    /')"
!
    fi

    if [ $e -eq ${CODE_SUCCESS} ]; then
        cat <<!
$(for key in ${extra[@]}; do echo ${key}=${!key}; done)
!
    fi

    return $e
}

function :core:execute() {
    local -i e=${CODE_USAGE_MODS}

    if [ $# -ge 1 ]; then
        e=${CODE_USAGE_MOD}

        if [ $# -ge 2 ]; then
            declare -g module=$1
            declare -g fn=$2
            shift 2

            if [ "$(type -t ${module}:${fn})" == "function" ]; then
                case ${g_FORMAT} in
                    dot|text|png)    SITE_IN_COLOR=0 ${module}:${fn} "${@}";;
                    html|email)      SITE_IN_COLOR=1 ${module}:${fn} "${@}";;
                    ansi)
                        if [ -t 1 ]; then
                            SITE_IN_COLOR=1 ${module}:${fn} "${@}"
                        else
                            SITE_IN_COLOR=0 ${module}:${fn} "${@}"
                        fi
                    ;;
                    *) core:raise EXCEPTION_SHOULD_NOT_GET_HERE "Format checks should have already taken place!";;
                esac
                e=$?

                if [ ${SITE_IN_COLOR} -eq 1 ]; then
                    if [ "$(type -t ${module}:${fn}:alert)" == "function" ]; then
                        cpf "%{r:ALERTS}%{bl:@}%{g:${SITE_PROFILE}} %{!function:${module} ${fn}}:\n"
                        while read line; do
                            set ${line}
                            local alert=$1
                            shift
                            theme ${alert} "${*}"
                        done < <(${module}:${fn}:alert)
                        cpf
                    fi

                    if [ -f ${g_CACHE_USED?} -a ${g_VERBOSE?} -eq 1 ]; then
                        cpf
                        local age
                        local cachefile
                        cpf "%{@comment:#. Cached Data} %{r:%s}\n" "-=["
                        while read cachefile; do
                            age=$(:core:age "${cachefile}")

                            case $(::core:cache:cachetype ${cachefile}) in
                                output)
                                    cpf "    %{b:%s} is %{@int:%ss} old..." "$(basename ${cachefile})" "${age}"
                                ;;
                                file)
                                    cpf "    %{@path:%s} is %{@int:%ss} old..." "${cachefile}" "${age}"
                                ;;
                            esac
                            theme WARN "CACHED"
                        done < ${g_CACHE_USED}
                        cpf "%{@comment:#.} %{r:%s}\n" "]=-"
                    fi
                fi
            else
                theme ERR_INTERNAL "Function ${module}:${fn} not defined!"
            fi
        fi
    fi

    if [ ${SITE_IN_COLOR} -eq 1 -a $e -eq 0 -a ${SECONDS} -ge 30 ]; then
        theme INFO "Execution time was ${SECONDS} seconds"
    fi

    return $e
}

function :core:git() {
    cd ${SITE_SCM?}
    git "$@"
    return $?
}

function ::core:dereference.eval() {
    #. NOTE: you myst eval the output of this function!
    #. take $1, and make it equal to ${$1}
    #.
    #. If the variable starts with _, remove it in the new variable
    #. Input: _my_var=something; something=( A B C )
    #. Output: my_var=( A B C )
    if [ ! -t 1 ]; then
        echo "unset ${1} && eval \$(declare -p ${!1}|sed -e 's/declare -\([a-qs-zA-Z]*\)r*\([a-qs-zA-Z]*\) ${!1}=\(.*\)/declare -\1\2 ${1}=\3/')";
    else
        core:raise EXCEPTION_BAD_FN_CALL \
            "This function must be called in a subshell, and evaled afterwards!"
    fi
}

function :core:functions() {
    local -i e=${CODE_FAILURE}

    if [ $# -eq 2 ]; then
        local fn_type=$1
        local module=$2
        case ${fn_type} in
            public)
                declare -F |
                    awk -F'[ ]' '$3~/^'${module}':/{print$3}' |
                    awk -F ':+' '{print$2}' |
                    sort -u
                e=${CODE_SUCCESS}
            ;;
            private)
                declare -F |
                    awk -F'[ ]' '$3~/^:'${module}':/{print$3}' |
                    awk -F ':+' '{print$3}' |
                    sort -u
                e=${CODE_SUCCESS}
            ;;
            internal)
                declare -F |
                    awk -F'[ ]' '$3~/^::'${module}':/{print$3}' |
                    awk -F ':+' '{print$3}' |
                    sort -u
                e=${CODE_SUCCESS}
            ;;
            *) core:raise EXCEPTION_BAD_FN_CALL;;
        esac
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function :core:usage() {
    local module=$1
    local fn=$2
    local mode=${3---short}
    [ $# -eq 2 ] && mode=${3---long}

    if [ ${#FUNCNAME[@]} -lt 4 ]; then
        cpf "%{+bo}%{bl:site}%{-bo} %{@version:%s}, %{wh:the system-administration bash scripting suite}\n" $(:core:git describe "--always")
        cpf "Using %{@path:%s} %{@version:%s}" "${BASH}" "${BASH_VERSION}"
        if [ ${#SITE_SHELL} -eq 0 ]; then
            cpf " %{@comment:(export SITE_SHELL to override)}"
        else
            cpf " %{r:(SITE_SHELL override active)}"
        fi
        printf "\n\n"
    fi

    if [ $# -eq 0 ]; then
        #. Usage for site
        cpf "%{wh:usage}%{bl:4}%{@user:${USER_USERNAME}}%{bl:@}%{g:${SITE_PROFILE}}\n"
        for profile in USER_MODULES CORE_MODULES; do
            eval $(::core:dereference.eval profile) #. Will create ${profile} array
            for module in ${!profile[@]}; do (
                local docstring="{no-docstr}"
                docstring=$(core:docstring ${module})
                core:softimport ${module}
                local -i ie=$?
                if [ $ie -eq ${CODE_IMPORT_ADMIN?} ]; then
                    continue
                elif [ $ie -eq ${CODE_IMPORT_GOOOD?} ]; then
                    local -a fn_public=( $(:core:functions public ${module}) )
                    local -a fn_private=( $(:core:functions private ${module}) )
                    if [ ${#fn_public[@]} -gt 0 ]; then
                        cpf "    "
                    else
                        cpf "%{y:!   }"
                    fi
                else
                    cpf "%{r:!!! }"
                fi

                cpf "%{bl:%s} %{!module:%s}:%{+bo}%{@int:%s}%{-bo}/%{@int:%s}"\
                    "${SITE_BASENAME}" "${module}"\
                    "${#fn_public[@]}" "${#fn_private[@]}"

                if [ $ie -eq ${CODE_IMPORT_GOOOD?} ]; then
                    cpf "%{@comment:%s}\n" "${docstring:+; ${docstring}}"
                else
                    cpf "; %{@warn:This module has not been set-up for use}\n"
                fi
            ); done
        done
    elif [ $# -eq 1 ]; then
        core:import ${module}
        cpf "%{wh:usage}%{bl:4}%{@user:${USER_USERNAME}}%{bl:@}%{g:${SITE_PROFILE}} %{!module:${module}}\n"
        local -a fns=( $(:core:functions public ${module}) )
        for fn in ${fns[@]}; do
            local usage_fn="${module}:${fn}:usage"
            local usagestr="{no-args}"
            if [ "$(type -t ${usage_fn})" == "function" ]; then
                usagestr="$(${usage_fn})"
                cpf "    %{bl:${SITE_BASENAME}} %{!function:${module}:${fn}} %{c:%s}\n" "${usagestr}"
            else
                cpf "    %{bl:${SITE_BASENAME}} %{!function:${module}:${fn}} %{bl:%s}\n" "${usagestr}"
            fi
        done

        if [ ${g_VERBOSE?} -eq 1 -a ${#FUNCNAME[@]} -lt 4 ]; then
            cpf "\n%{!module:${module}} %{g:changelog}\n"
            local modfile=${SITE_USER_MOD}/${module}
            [ -f ${modfile} ] || modfile=${SITE_CORE_MOD}/${module}
            cd ${SITE_CORE}
            :core:git --no-pager\
                log --follow --all --format=format:'    |___%C(bold blue)%h%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(bold white)— %an%C(reset)%C(bold yellow)%d%C(reset)'\
                --abbrev-commit --date=relative -- "${modfile}"
            cd ${OLDPWD}
            echo
        fi
        echo
    elif [ $# -ge 2 ]; then
        cpf "%{wh:usage}%{bl:4}%{@user:${USER_USERNAME}}%{bl:@}%{g:${SITE_PROFILE}} %{!function:${module}:${fn}}\n"
        cpf "    %{bl:${SITE_BASENAME}} %{!function:${module}:${fn}} "

        local usage_s=${module}:${fn}:usage
        if [ "$(type -t $usage_s)" == "function" ]; then
            cpf "%{c:%s}\n" "$(${usage_s})"
        else
            cpf "%{bl:%s}\n" "{no-args}"
        fi

        case ${mode} in
            --short) : pass ;;
            --long)
                local usage_l=${module}:${fn}:help
                local -i i=0
                if [ "$(type -t $usage_l)" == "function" ]; then
                    cpf
                    local indent=""
                    while read line; do
                        cpf "%{c:%s}\n" "${indent}${line}"
                        [ $i -eq 0 ] && indent+="    "
                        ((i++))
                    done <<< "`${usage_l}`"
                fi

                if [ ${#g_DUMP} -gt 0 ]; then
                    cpf
                    cpf "%{c:%s}\n" "Flags:"
                    echo "${g_DUMP}"
                fi
            ;;
        esac
    fi
}

function :core:complete() {
    local module=$1
    local fn=$2
    for afn in $(declare -F|awk -F'[ :]' '$3~/^'${module}'$/{print$4}'|sort -n); do
        local AC_${module}_${afn//./_}
    done
    local -a completed=( $(eval echo \${!AC_${module}_${fn//./_}*}) )
    if echo ${completed[@]} | grep -qE "\<AC_${module}_${fn//./_}\>"; then
        echo ${fn}
    else
        echo ${completed[@]//AC_${module}_/}
    fi
}

function core:wrapper() {
    if [ -e ${SITE_DEADMAN?} ]; then
        theme HAS_FAILED "CRITICAL ERROR; ABORTING!" >&2
        exit 1
    fi

    local -i e=${CODE_USAGE_MODS}

    local setdata
    local -i e_shflags
    setdata="$(::core:shflags.eval "${@}")"
    e_shflags=$?
    eval "${setdata}" #. sets module, fn, etc.

    local regex=':+[a-z0-9]+(:[a-z0-9]+) |*'
    core:softimport "${module?}"
    case $?/${module?}/${fn?} in
        ${CODE_IMPORT_UNSET?}/-/-)                                                                                       e=${CODE_USAGE_MODS} ;;
        ${CODE_IMPORT_GOOOD?}/*/-)    :core:execute          ${module}                2>&1 | grep --color -E "${regex}"; e=${PIPESTATUS[0]}   ;;
        ${CODE_IMPORT_GOOOD?}/*/::*) ::core:execute:private  ${module} ${fn:2} "${@}" 2>&1 | grep --color -E "${regex}"; e=${PIPESTATUS[0]}   ;;
        ${CODE_IMPORT_GOOOD?}/*/:*)  ::core:execute:internal ${module} ${fn:1} "${@}" 2>&1 | grep --color -E "${regex}"; e=${PIPESTATUS[0]}   ;;
        ${CODE_IMPORT_GOOOD?}/*/*)
            local -a completed=( $(:core:complete ${module} ${fn}) )

            local -A supported_formats=( [html]=1 [email]=1 [ansi]=1 [text]=1 [dot]=0 )
            if [ "$(type -t ${module}:${fn}:formats)" == "function" ]; then
                for format in $( ${module}:${fn}:formats ); do
                    supported_formats[${format}]=2
                done
            fi

            if [ ${#completed[@]} -eq 1 ]; then
                fn=${completed}
                if [ ${e_shflags} -eq ${CODE_SUCCESS} ]; then
                    if [ ${g_FORMAT?} == "email" ]; then
                        :core:execute ${module} ${completed} "${@}" 2>&1 |
                            grep --color -E "${regex}" |
                            ${SITE_CORE_LIBEXEC}/ansi2html |
                            mail -a "Content-type: text/html" -s "Site Report [${module} ${completed} ${@}]" ${USER_EMAIL}
                            e=${PIPESTATUS[3]}
                    elif [ ${g_FORMAT?} == "html" ]; then
                        :core:execute ${module} ${completed} "${@}" 2>&1 |
                            grep --color -E "${regex}" |
                            ${SITE_CORE_LIBEXEC}/ansi2html
                            e=${PIPESTATUS[2]}
                    elif [ -z "${supported_formats[${g_FORMAT}]}" ]; then
                        theme ERR_USAGE "That is not a supported format."
                        e=${CORE_FAILURE}
                    elif [ ${supported_formats[${g_FORMAT}]} -gt 0 ]; then
                        :core:execute ${module} ${completed} "${@}"
                        e=$?
                    else
                        theme ERR_USAGE "This function does not support that format."
                        e=${CORE_FAILURE}
                    fi
                else
                    e=${CODE_USAGE_FN_LONG}
                fi
            elif [ ${#completed[@]} -gt 1 ]; then
                theme ERR_USAGE "Did you mean one of the following:"
                for acfn in ${completed[@]}; do
                    echo "    ${SITE_BASENAME} ${module} ${acfn}"
                done
                e=${CODE_USAGE_FN_GUESS}
            else
                theme ERR_USAGE "${fn} not defined"
                e=${CODE_USAGE_MOD}
            fi
        ;;
        ${CODE_IMPORT_UNDEF?}/-/-) e=${CODE_USAGE_MODS};;
        ${CODE_IMPORT_UNDEF?}/*/*)
            theme ERR_USAGE "Module ${module} has not been defined"
            e=${CODE_FAILURE}
        ;;
        ${CODE_IMPORT_ERROR?}/*/*)
            theme HAS_FAILED "Module ${module} has errors"
            e=${CODE_FAILURE}
        ;;
        ${CODE_IMPORT_ADMIN?}/*/*)
            theme ERR_USAGE "Module ${module} has been administratively disabled"
            e=${CODE_DISABLED}
        ;;
        */*/*)
            e=${CODE_FAILURE}
            core:raise EXCEPTION_BAD_FN_CALL "Check call/caller to/of \`core:softimport ${@}'"
        ;;
    esac

    case $e in
        ${CODE_USAGE_MODS})    :core:usage ;;
        ${CODE_USAGE_SHORT})   :core:usage ${module} ;;
        ${CODE_USAGE_MOD})     :core:usage ${module} ;;
        ${CODE_USAGE_FN_LONG}) :core:usage ${module} ${fn} ;;
        0) : noop;;
    esac

    return $e
}
#. }=-
#. 1.12 Exceptions -={
EXCEPTION=63
EXCEPTION_BAD_FN_CALL=64
EXCEPTION_BAD_FN_RETURN_CODE=65
EXCEPTION_MISSING_EXEC=70
EXCEPTION_BAD_MODULE=71
EXCEPTION_DEPRECATED=72
EXCEPTION_MISSING_PERL_MOD=80
EXCEPTION_MISSING_PYTHON_MOD=81
EXCEPTION_MISSING_USER=82
EXCEPTION_INVALID_FQDN=90
EXCEPTION_SHOULD_NOT_GET_HERE=125
EXCEPTION_NOT_IMPLEMENTED=126
EXCEPTION_UNHANDLED=127
declare -A RAISE=(
    [${EXCEPTION_BAD_FN_CALL}]="Bad function call internally"
    [${EXCEPTION_BAD_FN_RETURN_CODE}]="Bad function return code internally"
    [${EXCEPTION_MISSING_EXEC}]="Required executable not found"
    [${EXCEPTION_MISSING_USER}]="Required user environment not set, or set to nil"
    [${EXCEPTION_BAD_MODULE}]="Bad module"
    [${EXCEPTION_DEPRECATED}]="Deprecated function call"
    [${EXCEPTION_MISSING_PERL_MOD}]="Required perl module missing"
    [${EXCEPTION_MISSING_PYTHON_MOD}]="Required python module missing"
    [${EXCEPTION_SHOULD_NOT_GET_HERE}]="Process flow should never get here"
)
function core:raise() {
    : !!! CRITICAL FAILURE !!!
    (
        cpf " %{r:failed with exception} %{g:$e}; %{c:traceback}:\n"
        local i=0
        local -i frames=${#BASH_LINENO[@]}
        #. ((frames-2)): skips main, the last one in arrays
        for ((i=frames-2; i>=0; i--)); do
            cpf "  File %{g:${BASH_SOURCE[i+1]}}, line %{g:${BASH_LINENO[i]}}, in %{r:${FUNCNAME[i+1]}()}\n"
            # Grab the source code of the line
            local code=$(sed -n "${BASH_LINENO[i]}{s/^ *//;p}" "${BASH_SOURCE[i+1]}")
            cpf "    %{wh:>>>} %{c}${code}%{N}\n"
        done
    ) > ${SITE_DEADMAN?}

    local -i e=$1

    if [[ $- =~ x ]]; then
        : !!! Exiting raise function early as we are being traced !!!
    else
        cpf "%{r}EXCEPTION%{+bo}[%s->%s]%{-bo}: %s%{N}:\n" "${e}" "$1" "${RAISE[$e]-[UNKNOWN EXCEPTION:$e]}" >&2

        if [ ${#module} -gt 0 ]; then
            if [ ${#fn} -gt 0 ]; then
                cpf "Function %{c:${module}:${fn}()}" 1>&2
                echo "Critical failure in function ${module}:${fn}()" >> ${SITE_DEADMAN?}
            else
                cpf "Module %{c:${module}}" 1>&2
                echo "Critical failure in module ${module}" >> ${SITE_DEADMAN?}
            fi
        else
            cpf "File %{@path:$0}" 1>&2
            echo "Critical failure in file ${0}" >> ${SITE_DEADMAN?}
        fi

        cpf " %{r:failed with exception} %{g:$e}; %{c:traceback}:\n" 1>&2
        local i=0
        local -i frames=${#BASH_LINENO[@]}
        #. ((frames-2)): skips main, the last one in arrays
        for ((i=frames-2; i>=0; i--)); do
            cpf "  File %{g:${BASH_SOURCE[i+1]}}, line %{g:${BASH_LINENO[i]}}, in %{r:${FUNCNAME[i+1]}()}\n" 1>&2
            # Grab the source code of the line
            local code=$(sed -n "${BASH_LINENO[i]}{s/^ *//;p}" "${BASH_SOURCE[i+1]}")
            cpf "    %{wh:>>>} %{c}${code}%{N}\n" 1>&2
        done
    fi

    exit $e
}
#. }=-
#. }=-
