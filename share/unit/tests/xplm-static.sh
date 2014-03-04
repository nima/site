# vim: tw=0:ts=4:sw=4:et:ft=bash
core:import util

#. XPLM -={
function testCoreXplmImport() {
    core:softimport xplm
    assertTrue 0x0 $?
}

function xplmTearDown() {
    : noop
}

function xplmStartUp() {
    : noop
}

#. testCoreXplmLoadvirtenvPrivate() -={
testCoreXplmLoadvirtenvPrivate() {
    : noop
}
#. }=-
#. testCoreXplmRequiresInternal() -={
testCoreXplmRequiresInternal() {
    : noop
}
#. }=-
#. testCoreXplmListInternal() -={
testCoreXplmListInternal() {
    : noop
}
#. }=-
#. testCoreXplmPurgeInternal() -={
function testCoreXplmPurgeInternal() {
    : noop
}
#. }=-
#. testCoreXplmInstallInternal() -={
function testCoreXplmInstallInternal() {
    : noop
}
function testCoreXplmInstallInternalRb() {
    core:import xplm

    cmd=":xplm:install rb"
    eval "${cmd}"
    assertTrue "[${cmd}]" $?
}
function testCoreXplmInstallInternalPy() {
    core:import xplm

    cmd=":xplm:install py"
    eval "${cmd}"
    assertTrue "[${cmd}]" $?
}
function testCoreXplmInstallInternalPl() {
    core:import xplm

    cmd=":xplm:install pl"
    eval "${cmd}"
    assertTrue "[${cmd}]" $?
}
#. }=-
#. testCoreXplmShellInternal() -={
testCoreXplmShellInternal() {
    : noop
}
#. }=-
#. testCoreXplmSearchInternal() -={
testCoreXplmSearchInternal() {
    : noop
}
#. }=-
#. testCoreXplmReplInternal() -={
testCoreXplmReplInternal() {
    : noop
}
#. }=-
#. testCoreXplmListPublic() -={
testCoreXplmListPublic() {
    : noop
}
#. }=-
#. testCoreXplmPurgePublic() -={
testCoreXplmPurgePublic() {
    : noop
}
#. }=-
#. testCoreXplmInstallPublic() -={
testCoreXplmInstallPublic() {
    : noop
}
#. }=-
#. testCoreXplmShellPublic() -={
testCoreXplmShellPublic() {
    : noop
}
#. }=-
#. testCoreXplmSearchPublic() -={
testCoreXplmSearchPublic() {
    : noop
}
#. }=-
#. testCoreXplmReplPublic() -={
testCoreXplmReplPublic() {
    : noop
}
#. }=-
#. }=-
