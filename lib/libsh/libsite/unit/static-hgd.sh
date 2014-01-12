#. Unit-testing static functions -={
function testCoreHgdDeletePublic() {
    core:softimport hgd
    local session=testCoreHgdDeletePublic
    if assertEquals t1 0 $?; then
        :hgd:save . ${session} '|(#10.1.2.3/29)' >${stdoutF?} 2>${stderrF?}
        if assertEquals t2 0 $?; then
            grep -qE "\<${session}\>" ${SITE_CACHE}/hgd.conf
            if assertEquals t3 0 $?; then
                hgd:delete ${session} >${stdoutF?} 2>${stderrF?}
                grep -qE "\<${session}\>" ${SITE_CACHE}/hgd.conf
                assertNotEquals t4 0 $?
            fi
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
