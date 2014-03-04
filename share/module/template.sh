# vim: tw=0:ts=4:sw=4:et:ft=bash

core:import util

:<<[core:docstring]
The module does X, Y and Z
[core:docstring]

function :template:funk() {
    local -i e=${CODE_FAILURE}

    if [ $# -eq 2 ]; then
        echo "*** main function logic ***"
        e=$?
    else
        core:raise EXCEPTION_BAD_FN_CALL
    fi

    return $e
}

function template:funk:usage() { echo "<mandatory> [<optional:default>]"; }
function template:funk() {
    local -i e=${CODE_DEFAULT}

    if [ $# -le 1 ]; then
        local mandatory=${1}
        local optional="${2:-default}"
        :template:funk "${mandatory}" "${optional}"
        if [ $e -eq ${CODE_SUCCESS} ]; then
            theme HAS_PASSED
        else
            theme HAS_FAILED
        fi
    fi

    return $e
}
