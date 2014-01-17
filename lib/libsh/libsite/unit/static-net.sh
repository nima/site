# vim: tw=0:ts=4:sw=4:et:ft=bash

function testCoreNetImport() {
    core:softimport net
    assertEquals 0 $?
}

function testCoreNetPortpersistInternal() {
    core:import net

    local -a tcpPorts=(
        $(netstat -ntl|awk -F '[: ]+' '$1~/^tcp$/&&$8~/^LISTEN$/{print$5}')
    )

    local -i i=0
    local -A scanned
    for tcpPort in ${tcpPorts[@]}; do
        :net:portpersist . localhost ${tcpPort} 1
        assertTrue ":net:portpersist(${tcpPort}).true?" $?
        scanned[${tcpPort}]=1
    done

    for tcpPort in {16..32}; do
        if [ ${scanned[${tcpPort}]-0} -eq 0 ]; then
            :net:portpersist . localhost ${tcpPort} 1
            assertFalse ":net:portpersist(${tcpPort}).false?" $?
        fi
    done
}
