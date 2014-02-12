# vim: tw=0:ts=4:sw=4:et:ft=bash
core:import util
core:import net

function testCoreTunnelImport() {
    core:softimport tunnel
    assertEquals 0 $?
}

function tunnelTearDown() {
    : noop
    #sudo rm -rf ~root/.ssh
    #rm -rf ~/.ssh/id_rsa.pub
    #rm -rf ~/.ssh/id_rsa
}

function tunnelSetUp() {
    case ${g_MODE?} in
        prime)
            : noop
        ;;
        execute)
            export g_QDN_A="host-a.unit-test.site.org"
            export g_PID=0

            ssh-keygen -q -t rsa -N "" -f ~/.ssh/id_rsa
            cat <<! | sudo tee -a /etc/hosts >/dev/null
127.0.0.1   ${g_QDN_A}
127.0.0.2   host-b.unit-test.site.org
127.0.0.3   host-c.unit-test.site.org
127.0.0.4   host-d.unit-test.site.org
127.0.0.5   host-e.unit-test.site.org
127.0.0.6   host-f.unit-test.site.org
127.0.0.7   host-g.unit-test.site.org
127.0.0.8   host-h.unit-test.site.org
127.0.0.9   host-i.unit-test.site.org
!
            touch ~/.ssh/known_hosts

            local ip
            for ip in 127.0.0.{1..9}; do
                ssh-keyscan -t rsa ${ip} >> ~/.ssh/known_hosts 2>/dev/null
            done

            local hostname
            for hostname in host-{a..i}.unit-test.site.org; do
                ssh-keyscan -t rsa ${hostname} >> ~/.ssh/known_hosts 2>/dev/null
            done

            install -m 400 ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
        ;;
        *)
            exit 127
        ;;
    esac
}

function test_1_0_CoreTunnelStartPublic() {
    core:import tunnel

    core:wrapper tunnel start ${g_QDN_A} >${stdoutF?} 2>${stderrF?}
    assertTrue "0x1" $?
}

function test_1_1_CoreTunnelStartInternal() {
    core:import tunnel

    :tunnel:start ${g_QDN_A}
    assertEquals "0x2" ${CODE_E01?} $?
}

function test_1_2_CoreTunnelStartPublic() {
    core:import tunnel

    core:wrapper tunnel start ${g_QDN_A} >${stdoutF?} 2>${stderrF?}
    assertTrue "0x1" $?
}

function test_1_3_CoreTunnelCreateInternal() {
    core:import tunnel

    :net:localportping 8000
    assertFalse "0x1" $?

    :tunnel:create ${g_QDN_A} localhost 8000 localhost 22
    assertTrue "0x2" $?

    :net:localportping 8000
    assertTrue "0x3" $?

    :tunnel:create ${g_QDN_A} localhost 8000 localhost 22
    assertEquals "0x4" ${CODE_E01?} $?
}

function test_1_4_CoreTunnelCreatePublic() {
    core:import tunnel

    core:wrapper tunnel create ${g_QDN_A}\
        -l localhost 8000 -r localhost 22 >${stdoutF?} 2>${stderrF?}
    assertEquals "0x4" ${CODE_E01?} $?
}

function test_1_5_CoreTunnelStatusPublic() {
    core:import tunnel

    core:wrapper tunnel status ${g_QDN_A} >${stdoutF?} 2>${stderrF?}
    assertTrue "0x0" $?
}

function test_1_6_CoreTunnelPidInternal() {
    core:import tunnel

    g_PID=$(:tunnel:pid ${g_QDN_A})
    assertTrue "0x1" $?

    [ ${g_PID} -gt 0 ]
    assertTrue "0x1" $?
}

function test_1_7_CoreTunnelListInternal() {
    core:import tunnel

    local ports
    ports=$(:tunnel:list ${g_PID})
    assertTrue "0x1" $?

    [ ${ports} -eq 8000 ]
    assertTrue "0x2" $?
}

function test_1_8_CoreTunnelStopInternal() {
    core:import tunnel

    local -i pid
    pid=$(:tunnel:stop ${g_QDN_A})
    assertTrue "0x0" $?

    [ ${pid} -eq ${g_PID} ]
    assertTrue "0x1" $?

    pid=$(:tunnel:stop ${g_QDN_A})
    assertFalse "0x2" $?

    [ ${pid} -eq 0 ]
    assertTrue "0x4" $?
}

function test_1_9_CoreTunnelStopPublic() {
    core:import tunnel

    core:wrapper tunnel stop ${g_QDN_A} >${stdoutF?} 2>${stderrF?}
    assertTrue "0x1" $?
}
