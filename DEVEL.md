DEVELOPER'S CORNER
==================

TERMS & JARGONS
---------------

<shn>       the short hostname
<sdn>       the subdomain name, without the domain itself
<hgd>       host-group-directives
<qdn>       <shn>.<sdn>
<fqdn>      <shn>.<sdn>.<tld>
<hnh>       hostname hint; either a <shn>, or a <qdn>
<sdh>       subdomain hint
<lhi>       ldap-host index

### Variable Scope

All global variables are of the pattern:

    g_[A-Z]+

...having said that, their use must be minimized.

### Function Scope

* In site - there are modules, and there are module functions.
* Almost all functions belond to a particular module, and this is clearly
  visible from the name of the function:

    function <module>:<function>()     #. public   functions
    function :<module>:<function>()    #. internal functions
    function ::<module>:<function>()   #. private  functions

* Now let's look at the 3 type of functions:

<public>      functions in site that are directly exposed to the user
<private>  :: functions in site that are strictly for the benefit of a given
              modules
<internal>  : functions that are not exposed publicly, but are there for use
              by other modules

#### Public Functions

Public functions can call ::private and/or :internal functions, they look
after the "view", and should never do any actual calculative work, or
execute any interesting commands, other than calling their respective
:internal counterparts, or other :internal functions.

Basically anything you expect the user to see from the commandline must be
carried out by a public function; the public function therefore is primarily
providing the "view" component of an MVC architecture.  It also handles
argument parsing.

#### :Internal Functions
:internal functions can be called from any function from any module are the
major workhorse of the framework, and there are many of them.

They should not take variable arguments, and any variables that can take a
default value must be predetermined by the public caller at the start of the
chain of calls.

#### ::Private Functions
::private function must not be called from outside of their module.  These
functions generally contain either dirty code, or code that is way too
specific to the calling function.  For the same reason, they generally
only have a single :private caller, and thus named after the caller
(prefixed with a colon).  Don't write these unless you want/need to hide
away something in order to make reading the :internal function that calls
it better; these functions should be thought of as the `third leg'.

---

The decision of segregating this code between private and internal is this: Is
the function providing a service to a single internal function?  If so, make it
private.  If the function is providing a service to a host of internal functions,
and internal functions from other modules, then make it internal.

The following table summarises the above into a table which illustrates what class
of module functions can call what other class of module function:

|                     | Public Callee | Internal Callee | Private Callee |
|---------------------|---------------|-----------------|----------------|
| **Public Caller**   | No            | Yes             | Yes*           |
| **Internal Caller** | No            | Yes             | Yes*           |
| **Private Caller**  | No            | Yes             | Yes*           |

* - limited to private functions of the same module as the caller.

### Host-Group Directives (HGD)

This is best described with an example of two:

    site hgd resolve '&(|(+sap2_cs,+sap2_app),+sap2_pink)'

######. vim:syntax=markdown
