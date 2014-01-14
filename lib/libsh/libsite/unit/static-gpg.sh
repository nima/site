# vim: tw=0:ts=4:sw=4:et:ft=bash
function testCoreGpgImport() {
    core:softimport gpg
    assertEquals 0x1 0 $?
}

function test_1_1_CoreGpgKeypathPrivate() {
    core:softimport gpg

    PROFILE=UNITTEST ::gpg:keypath '.' >${stdoutF?} 2>${stderrF?}
    assertTrue 0x1 $?
    assertEquals 0x2 1 $(cat ${stdoutF}|wc -w)

    PROFILE=UNITTEST ::gpg:keypath '*' >${stdoutF?} 2>${stderrF?}
    assertFalse 0x3 $?
    assertEquals 0x4 0 $(cat ${stdoutF}|wc -w)
}

function test_2_1_CoreGpgListInternal() {
    core:softimport gpg

    #. Should be none to list at first
    PROFILE=UNITTEST :gpg:list >${stdoutF?} 2>${stderrF?}
    assertFalse 0x1 $?
}

function test_2_2_CoreGpgCreateInternal() {
    core:softimport gpg

    #. Create one
    PROFILE=UNITTEST :gpg:create >${stdoutF?} 2>${stderrF?}
    assertTrue 0x1 $?

    #. List it
    PROFILE=UNITTEST :gpg:list >${stdoutF?} 2>${stderrF?}
    assertTrue 0x2 $?

    local gpgkid=( $(cat ${stdoutF?}) )
    assertEquals 0x3 2 ${#gpgkid[@]}
    assertEquals 0x4 10 ${#gpgkid[1]}
}

function test_2_3_CoreGpgDeleteInternal() {
    core:softimport gpg

    local gpgkid=( $(cat ${stdoutF?}) )

    #. Delete it
    PROFILE=UNITTEST :gpg:delete ${gpgkid[1]} >${stdoutF?} 2>${stderrF?}
    assertTrue 0x1 $?

    #. Should be none to list again
    PROFILE=UNITTEST :gpg:list >${stdoutF?} 2>${stderrF?}
    assertFalse 0x2 $?
}

function test_3_1_CoreGpgListPublic() {
    core:softimport gpg

    #. Should be none to list at first
    PROFILE=UNITTEST core:wrapper gpg list >${stdoutF?} 2>${stderrF?}
    assertFalse 0x1 $?
}

function test_3_2_CoreGpgCreatePublic() {
    core:softimport gpg

    #. Create one
    PROFILE=UNITTEST core:wrapper gpg create >${stdoutF?} 2>${stderrF?}
    assertTrue 0x1 $?

    #. List it
    PROFILE=UNITTEST :gpg:list >${stdoutF?} 2>${stderrF?}
    assertTrue 0x2 $?
    local gpgkid=( $(cat ${stdoutF?}) )
    assertEquals 0x3 2 ${#gpgkid[@]}
    assertEquals 0x4 10 ${#gpgkid[1]}
}

function test_3_3_CoreGpgDeletePublic() {
    core:softimport gpg

    local gpgkid=( $(cat ${stdoutF?}) )
    if assertEquals 0x1 2 ${#gpgkid[@]}; then
        #. Delete it
        PROFILE=UNITTEST core:wrapper gpg delete ${gpgkid[1]} >${stdoutF?} 2>${stderrF?}
        assertTrue 0x1 $?

        #. Try to delete it again and fail
        PROFILE=UNITTEST core:wrapper gpg delete ${gpgkid[1]} >${stdoutF?} 2>${stderrF?}
        assertFalse 0x2 $?

        #. Should be none to list again
        PROFILE=UNITTEST core:wrapper gpg list >${stdoutF?} 2>${stderrF?}
        assertFalse 0x3 $?
    fi
}
