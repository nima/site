INTRO
=====
Q: WTF is it?
A: A bash sys-admin framework for standardising scripting.

---

REQUIREMENTS
============

You need bash v4.0+

You need gnu grep v2.0+ (probably)

You need the following perl modules for the VMware stuff to work:
    - TODO

---

INSTALLATION
============

    export PROFILE=DEC
    make

This will installs everything required monolithically under `~/.site/' - and
that is mostly just symbolic links pointing back to the git area, and one
`extern' directory for any 3rd party requirements.  The installer will pull
all such 3rd party software down into this folder and set up links as necessary.

---

DEVELOPER'S CORNER
==================

TERMS & JARGONS
---------------

<shn>       the short hostname
<sdn>       the subdomain name, without the domain itself
<hgd>       host-group-directives
<fqdn>      <shn>.<sdn>.<domain>
<hosthint>  either a <shn>, or a <shn>.<sdn>


### Function Scopes

* In site - there are modules, and there are module functions.
* Almost all functions belond to a particular module, and this is clearly
  visible from the name of the function:

    function <module>:<function>()     #. <public> functions
    function :<module>:<function>()    #. <private> functions
    function ::<module>:<function>()   #. <internal> functions

* Now let's look at the 3 type of functions:

<public>    functions in site that are directly exposed to the user
<private>   functions in site that are strictly for the benefit of a given
            modules
<internal>  functions that are not exposed publicly, but are there for use
            by other modules

Basically anything you expect the user to see from the commandline must be
defined as a public function.  However, the inner workings - or the
"intelligt" part of all such functions should not be written in the public
function, but either in the internal, or private function counterpart of that
function.  So in essence, the public function is purely for the "view" layer,
it adds color, formatting and other display-oriented properties to the output.

The decision of segregating this code between private and internal is again
related to abstraction.  The question to ask is: is this function tightly-bound
to the module itself, and so should be completely hidden away from all other
modules, or is it something that other modules would benefit from and should
have access to?

### Host-Group Directives (HGD)

TODO
