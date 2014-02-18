# vim: tw=0:ts=4:sw=4:et:ft=bash
core:import util

function testCoreDnsImport() {
    core:softimport dns
    assertTrue 0x0 $?
}

function dnsTearDown() {
    : noop
}

function dnsStartUp() {
    : noop
}

#. -={
#. testCoreDnsSubdomainsInternal -={
function testCoreDnsSubdomainsInternal() {
    core:import dns

    local -a sdns
    local -a results

    sdns=( $(:dns:subdomains . full) )
    assertTrue 1.1 $?
    results=(
        unit-tests.mgmt.site
        networks.mgmt.site
        systems.mgmt.site
        api.site.org
        products.site.org
        support.site.org
    )
    assertEquals 1.2 "$(:util:join , results)" "$(:util:join , sdns)"

    sdns=( $(:dns:subdomains m short) )
    assertTrue 2.1 $?
    results=(
        unit-tests
        networks
        systems
    )
    assertEquals 2.2 "$(:util:join , results)" "$(:util:join , sdns)"
    sdns=( $(:dns:subdomains m full) )
    assertTrue 2.3 $?
    results=(
        unit-tests.mgmt.site
        networks.mgmt.site
        systems.mgmt.site
    )
    assertEquals 2.4 "$(:util:join , results)" "$(:util:join , sdns)"

    sdns=( $(:dns:subdomains p short) )
    assertTrue 3.1 $?
    results=(
        api
        products
        support
    )
    assertEquals 3.2 "$(:util:join , results)" "$(:util:join , sdns)"
    sdns=( $(:dns:subdomains p full) )
    assertTrue 3.3 $?
    results=(
        api.site.org
        products.site.org
        support.site.org
    )
    assertEquals 3.4 "$(:util:join , results)" "$(:util:join , sdns)"

    sdns=( $(:dns:subdomains z) )
    assertFalse 4.1 $?
    [ -z "$(:util:join , sdns)" ]
    assertTrue 4.2 $?
}
#. }=-
#. testCoreDnsSubdomainsPublic -={
function testCoreDnsSubdomainsPublic() {
    core:import dns

    local data
    data=( $(core:wrapper dns subdomains -T.) )
    assertTrue   1.1 $?
    assertEquals 1.2 6 ${#data[@]}

    local data
    data=( $(core:wrapper dns subdomains -Tm) )
    assertTrue   2.1 $?
    assertEquals 2.2 3 ${#data[@]}

    local data
    data=( $(core:wrapper dns subdomains -Tp) )
    assertTrue   3.1 $?
    assertEquals 3.2 3 ${#data[@]}
}
#. }=-
#. testCoreDnsInspectInternalCsv -={
function testCoreDnsInspectInternal() {
    core:import dns

    #:dns:inspect.csv 'trailer0dot.unit-tests.mgmt.site' >${stdoutF?} 2>${stderrF?}
    #assertTrue   1.1 $?
    #:dns:inspect.csv 'trailer1dot.unit-tests.mgmt.site.' >${stdoutF?} 2>${stderrF?}
    #assertFalse  1.2 $? #. TODO This is technically a valid DNS name, so ...
    #:dns:inspect.csv 'trailer2dot.unit-tests.mgmt.site..' >${stdoutF?} 2>${stderrF?}
    #assertFalse  1.3 $?

    local -a data

    data=( $(:dns:inspect.csv 'host-8f.api.site.org' a) )
    assertTrue   1.1.1 $?
    assertEquals 1.1.2 1 ${#data[@]}
    assertEquals 1.1.3 "a,host-8f.api.site.org,fqdn,p,api,site.org,host-8f.api.site.org,127.2.8.15,1" "${data[0]}"

    data=( $(:dns:inspect.csv 'host-ca.products.site.org' a) )
    assertTrue   1.2.1 $?
    assertEquals 1.2.2 1 ${#data[@]}
    assertEquals 1.2.3 "a,host-ca.products.site.org,fqdn,p,products,site.org,host-ca.products.site.org,127.2.12.10,1" "${data[0]}"

    data=( $(:dns:inspect.csv 'host-d.mgmt.site' a) )
    assertTrue   2.1 $?
    assertEquals 2.2 1 ${#data[@]}
    assertEquals 2.3 "a,host-d.mgmt.site,fqdn,m,,mgmt.site,host-d.mgmt.site,127.1.13.99,2" "${data[0]}"

    data=( $(:dns:inspect.csv 'google-public-dns-a.google.com' a) )
    assertTrue   3.1 $?
    assertEquals 3.2 1 ${#data[@]}
    assertEquals 3.3 "a,google-public-dns-a.google.com,ext,-,-,-,google-public-dns-a.google.com,8.8.8.8,3" "${data[0]}"

    data=( $(:dns:inspect.csv 'host-ca.networks' a) )
    assertTrue   4.1 $?
    assertEquals 4.2 1 ${#data[@]}
    assertEquals 4.3 "a,host-ca.networks,qdn,m,networks,mgmt.site,host-ca.networks.mgmt.site,127.1.12.10,6" "${data[0]}"

    data=( $(:dns:inspect.csv 'host-ca' a) )
    assertTrue   5.1 $?
    assertEquals 5.2 2 ${#data[@]}
    assertEquals 5.3 "a,host-ca,shn,m,networks,mgmt.site,host-ca.networks.mgmt.site,127.1.12.10,7" "${data[0]}"
    assertEquals 5.4 "a,host-ca,shn,p,products,site.org,host-ca.products.site.org,127.2.12.10,7" "${data[1]}"
}
#. }=-
#. testCoreDnsLookupInternalCsv -={
function testCoreDnsLookupInternal() {
    core:import dns

    local -a data

    data=( $(:dns:lookup.csv p a 'host-8f') )
    assertTrue   1.1 $?
    assertEquals 1.2 1 ${#data[@]}
    assertEquals 1.3 "a,host-8f,shn,p,api,site.org,host-8f.api.site.org,127.2.8.15,7" "${data[0]}"

    data=( $(:dns:lookup.csv m a 'host-8f') )
    assertTrue   2.1 $?
    assertEquals 2.2 1 ${#data[@]}
    assertEquals 2.3 "a,host-8f,shn,m,unit-tests,mgmt.site,host-8f.unit-tests.mgmt.site,127.1.8.15,7" "${data[0]}"

    data=( $(:dns:lookup.csv pm ca 'host-8f') )
    assertTrue   3.1 $?
    assertEquals 3.2 2 ${#data[@]}
    assertEquals 3.3 "a,host-8f,shn,m,unit-tests,mgmt.site,host-8f.unit-tests.mgmt.site,127.1.8.15,7" "${data[0]}"
    assertEquals 3.4 "a,host-8f,shn,p,api,site.org,host-8f.api.site.org,127.2.8.15,7" "${data[1]}"

    data=( $(:dns:lookup.csv mp ac 'host-8f') )
    assertTrue   4.1 $?
    assertEquals 4.2 2 ${#data[@]}
    assertEquals 4.3 "a,host-8f,shn,m,unit-tests,mgmt.site,host-8f.unit-tests.mgmt.site,127.1.8.15,7" "${data[0]}"
    assertEquals 4.3 "a,host-8f,shn,p,api,site.org,host-8f.api.site.org,127.2.8.15,7" "${data[1]}"
}
#. }=-
#. testCoreDnsLookupPublic -={
function testCoreDnsLookupPublic() {
    core:import dns

    local hostname

    hostname=host-f9.unit-tests.mgmt.site
    core:wrapper dns lookup ${hostname} >${stdoutF?} 2>${stderrF?}
    assertTrue   1.1 $?

    hostname=nohost.api.site.org
    core:wrapper dns lookup ${hostname} >${stdoutF?} 2>${stderrF?}
    assertFalse  1.2 $?
}
#. }=-
#. testCoreDnsResolveInternal -={
function testCoreDnsResolveInternal() {
    core:import dns

    local data

    data=$(:dns:resolve host-88.support.site.org a)
    assertTrue  1.1 $?

    data=$(:dns:resolve nosuchhost.support.site.org a)
    assertFalse 1.2 $?

    data=$(:dns:resolve www.google.com a)
    assertTrue  1.3 $?
}
#. }=-
#. testCoreDnsTldidsPublic -={
function testCoreDnsTldidsPublic() {
    core:import dns

    local data

    data=$(core:wrapper dns tldids)
    assertTrue  1.1 $?

    data=$(core:wrapper dns tldids '?')
    assertFalse 1.2 $?
}
#. }=-
#. testCoreDnsGetInternal -={
function testCoreDnsGetInternal() {
    core:import dns

    local data
    data=$(:dns:get . usdn www.google.com)
    assertTrue   1.1 $?
    data=$(:dns:get . qdn www.google.com)
    assertTrue   1.2 $?
    data=$(:dns:get . fqdn www.google.com)
    assertTrue   1.3 $?
    data=$(:dns:get . resolved www.google.com)
    assertTrue   1.4 $?
}
#. }=-
#. testCoreDnsFqdnPublic -={
function testCoreDnsFqdnPublic() {
    core:import dns

    local data

    data=$(core:wrapper dns fqdn www.google.com)
    assertTrue   1.1 $?
    assertEquals 1.2 "www.google.com" "${data}"
}
#. }=-
#. testCoreDnsQdnPublic -={
function testCoreDnsQdnPublic() {
    core:import dns

    local data

    data=$(core:wrapper dns qdn www.google.com)
    assertTrue   1.1 $?
    assertEquals 1.2 "www.google.com" "${data}"
}
#. }=-
#. testCoreDnsUsdnPublic -={
function testCoreDnsUsdnPublic() {
    core:import dns

    local data

    data=$(core:wrapper dns usdn www.google.com)
    assertTrue   1.1 $?
    assertEquals 1.2 "-" "${data}"
}
#. }=-
#. testCoreDnsIscnameInternal -={
function testCoreDnsIscnameInternal() {
    core:import dns

    :dns:iscname . www.google.com
    assertFalse  1.1 $?
}
#. }=-
#. testCoreDnsIsarecordInternal -={
function testCoreDnsIsarecordInternal() {
    core:import dns

    :dns:isarecord . www.google.com
    assertTrue   1.1 $?
}
#. }=-
#. }=-
