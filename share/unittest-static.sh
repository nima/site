#. Unit-testing static functions -={
function testCoreHgdResolvePublic() {
    core:softimport hgd
    if assertEquals 0 $?; then
        hgd:resolve '|(#10.1.2.3/29)' >${stdoutF?} 2>${stderrF?}
        if assertEquals 0 $?; then
            for ip in "10.1.2.6" "10.1.2.4" "10.1.2.5" "10.1.2.2" "10.1.2.3" "10.1.2.1"; do
                grep -qE "\<${ip}\>" ${stdoutF}
                assertEquals 0 $?
            done
        fi
    fi
}

function testCoreHgdResolvePrivate() {
    core:softimport hgd
    if assertEquals 0 $?; then
        ::hgd:resolve '&(#10.1.2.3/29)' >${stdoutF?} 2>${stderrF?}
        if assertEquals 0 $?; then
            local so=$(echo -e "#10.1.2.3/29\n10.1.2.1 10.1.2.2 10.1.2.3 10.1.2.4 10.1.2.5 10.1.2.6")
            assertEquals "${so}" "$(cat ${stdoutF})"
        fi
    fi
}

function testPySetsAND() {
    cat <<! | ${SITE_LIBEXEC_CORE}/sets '&(nucky,rothstein,waxy)' >${stdoutF?} 2>${stderrF?}
nucky
aaa
bbb
ccc
ddd

rothstein
bbb
ccc
ddd
eee

waxy
ccc
ddd
eee
fff
!
    if assertEquals 0 $?; then
        assertEquals "ccc ddd" "$(cat ${stdoutF})"
    fi
}

function testPySetsOR() {
    cat <<! | ${SITE_LIBEXEC_CORE}/sets '|(nucky,rothstein,waxy)' >${stdoutF?} 2>${stderrF?}
nucky
aaa
bbb
ccc
ddd

rothstein
bbb
ccc
ddd
eee

waxy
ccc
ddd
eee
fff
!
    if assertEquals 0 $?; then
        assertEquals "aaa bbb eee fff ccc ddd" "$(cat ${stdoutF})"
    fi
}
#. }=-

