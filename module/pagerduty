# vim: tw=0:ts=4:sw=4:et:ft=bash

:<<[core:docstring]
PagerDuty module
[core:docstring]

#. See http://developer.pagerduty.com/documentation/rest to extend functionality
#. PagerDuty -={
core:import util

core:import util
core:import vault

core:requires curl
core:requires ENV USER_PAGERDUTY_HOST
core:requires VAULT PAGERDUTY_API_KEY

#. pagerduty:query -={
function :pagerduty:query() {
    local -i e=${CODE_FAILURE?}

    local secret
    case $#:$1 in
        1:incidents)
            secret=$(:vault:read PAGERDUTY_API_KEY)
            if [ $? -eq 0 ]; then
                curl -s\
                    -H "Content-type: application/json"\
                    -H "Authorization: Token token=${secret}"\
                    -X GET -G \
                    --data-urlencode "status=triggered,acknowledged" \
                    "https://${USER_PAGERDUTY_HOST?}/api/v1/${1}"
                e=$?
            fi
        ;;
        1:schedules)
            secret=$(:vault:read PAGERDUTY_API_KEY)
            if [ $? -eq 0 ]; then
                curl -s\
                    -H "Content-type: application/json"\
                    -H "Authorization: Token token=${secret}"\
                    -X GET -G \
                    "https://${USER_PAGERDUTY_HOST?}/api/v1/${1}"
                e=$?
            fi
        ;;
        2:schedules)
            secret=$(:vault:read PAGERDUTY_API_KEY)
            if [ $? -eq 0 ]; then
                curl -s\
                    -H "Content-type: application/json"\
                    -H "Authorization: Token token=${secret}"\
                    --data-urlencode "since=$(date --iso-8601=minutes -d "0 hour")"\
                    --data-urlencode "until=$(date --iso-8601=minutes -d "12 hour")"\
                    -X GET -G \
                    "https://${USER_PAGERDUTY_HOST?}/api/v1/${1}/${2}"
                e=$?
            fi
        ;;
        *)
            core:raise EXCEPTION_BAD_FN_CALL
        ;;
    esac

    return $e
}

function pagerduty:query:usage() { echo "incidents | schedules [<schedule-id>]"; }
function pagerduty:query() {
    local -i e=${CODE_DEFAULT?}

    case $#:$1 in
        1:schedules|1:incidents)
            :pagerduty:query $1 | :util:json -a
            e=$?
        ;;
        1:schedules)
            :pagerduty:query $1 |
                :util:json -a 'schedule.final_schedule.rendered_schedule_entries' |
                :util:json -a start end user.name
            e=$?
        ;;
        2:schedules)
            :pagerduty:query $1 $2 |
                :util:json -a 'schedule.final_schedule.rendered_schedule_entries' |
                :util:json -a start end user.name
            e=$?
        ;;
    esac

    return $e
}
#. }=-
#. }=-
