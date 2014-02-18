[![Build Status](https://travis-ci.org/nima/site.png?branch=stable)](https://travis-ci.org/nima/site)
[![views](https://sourcegraph.com/api/repos/github.com/nima/site/counters/views.png)](https://sourcegraph.com/github.com/nima/site)
[![authors](https://sourcegraph.com/api/repos/github.com/nima/site/badges/authors.png)](https://sourcegraph.com/github.com/nima/site)
[![status](https://sourcegraph.com/api/repos/github.com/nima/site/badges/status.png)](https://sourcegraph.com/github.com/nima/site)

# OVERVIEW
**MISSION STATEMENT**: _To simplify and standardize collaborative scripting, reporting and automation tasks_

**TARGET AUDIENCE**: _System Administrators, System Engineers, DevOps, System Reliability Engineers (SRE), Test Engineers_

Site is written for system administrators, system engineers, devOps, or automation engineers.  It is a superset of bash, and structured to scale with your scripting requirements.

## The Code
Site is broken up into two main chunks:

1. The bits that we write:
    * the *site engine*: `libsite.sh`
    * the *core modules*: `module/*`

2. The bits that you write:
    * the *user modules*: `~/.site/module/*`

## The Config
Site is configured in two places:

1. One for *your organization*: `~/.site/etc/site.conf`
2. One just for *you*: `~/.siterc`

---
# REQUIREMENTS

## Core Requirements

You need bash v4.0+ to start with, but this is easier than you might think:  if your version of bash is older, simply compile a newer one locally in you home directory, and set the environment variable `SITE_SHELL` to point to it.  You don't even need to do this in your user profile, simply place it (and any other overrides) into your `~/.siterc` or ~/.site/etc/site.conf`.  More on those files later!

You also need a handful of utilities and interpreters such as gnu grep, gawk, gsed, nc, socat, etc. The full list is covered in the installation section bellow.

## Additional Requirements

The site modules will themselves check for any python, ruby, or perl module you need for that particular module.


---
# INSTALLATION
0. Clone It

    ```bash
    cd ~/
    git clone https://github.com/nima/site.git
    cd site
    ```
1. Install prerequisite software

    Do what [Travis](https://travis-ci.org/nima/site/builds) does:
    ```bash
    sed -ne '/^before_install:/,/^$/{/^ /p}' .travis.yml
    ```
2. Set up yout new `PROFILE`

    ```bash
    export PROFILE=MYCOMPANY
    mkdir -p profile/${PROFILE}/etc/
    mkdir -p profile/${PROFILE}/module/
    cp share/examples/site.conf.eg profile/${PROFILE}/etc/
    cp share/examples/siterc.eg ~/.siterc
    ```
3. Install

    ```bash
    make install
    ```

## Filesystem Layout
Site is designed to be run by your local user; it is designed to be installed on your desktop machine, and it will communicate with your hosts remotely.  You should never need to install site on a server.

### Site will not crap all over your filesystem or home directory
Here are the only files that will exist outside of `${SITE_SCM}` (where you cloned site to):

    * `~/bin/site`
    * `~/.site/`
    * `~/.siterc`
    * `~/.secrets`

The installer installs everything required monolithically under `~/.site/`, and even that is just a set of symbolic links pointing back to various folders within `${SITE_SCM}`.

The `~/.siterc` is where you can store configuration overrides for you particular user, and `~/.secrets` is a GPG-encrypted file where you cam store all your passwords.  Site will provide you with the necessary high-level tools to create, edit, and read to and from this file, so you don't have to invoke GPG commands directly.

### Site can be uninstalled as easily as it can be installed
To uninstall, simply run `make uninstall`, and if you want to delete all downloaded third-party software as well, then run `make purge`.

### Site doesn't expect your bash profile to be changed
Instead, you ever need to tell it to use a different executable, simply do so via `~/.siterc`; for example:

```bash
function grep() { /usr/local/bin/grep "$@"; return $?; }
```
That means that you do not need to change your `PATH` to accomodate it, and the only environment variable that site cares (deeply) about, is `PROFILE`.

---
# HELP

## Asking for Help (Support)
If you need help, please feel free to contact support on `github at nima dot id dot au`.

## Offering to Help (Contribustion)
We're always looking for users and developers.  Simply telling us about your experience installing and using site is of great value to us.  If you want to get your hands dirty, well send us a pull request!  Remember site is modular, and there is no reason why you couldn't add your own modules to site.  If those modules are generic and could be of use to other users, we would love to hear from you!

---
# PHILOSOPHY
Instead of hardcoding tediously long and complex commands over and over again in various scripts and various places, implement them once, and implement them well.  That is all you need to do (as far as scripting habits go), and you can start using site (almost) seamlessly.

All you have to do is to break up your scripts into small, single-purpose *functions*, and then group them contextually into *modules*.  Of course you don't have to break your scripts up at all, but if you want to reuse any part of that script, the this is the best way forward.

## Simplicity
Site is simple to use; and most UI concerns are automatically accounted for, simply as a result of you writing your code within the framework.

For example, if you implement a function called `say:hello()` in `~/.site/profile/module/say`, you will get basic usage for free:

```
% site
Using /bin/bash 4.2.37(1)-release (export SITE_SHELL to override)

usage4nima@SITE01
    site say:1/0; A module that greets the world
    ...
%
```

Now that we know of the `say` module:
```
% site say
Using /bin/bash 4.2.37(1)-release (export SITE_SHELL to override)

usage4nima@SITE01 say
    site say hello {no-args}
%
```

And now, that we know how to use it:
```
% site say hello
Hello World!
%
```

## Verifiability
### Unit Testing Framework
Scripts change over time, and so unit-testing is as relevant to systems scripts as it is to any piece of software.  Site comes with a flexible unit-testing module. This module reads everything it needs to know about every function test from a unit-testing configuration file, and warns you for functions that are missing unit-test data.

```
% site unit test
```

### Bash Traceback
That's right, we have a traceback so you can debug your scripts (site user modules).  Of course bash doesn't provide such functionality natively, so we had to be creative.

## Security Measures
Site doesn't expect to be run as root; in fact it should _never_ be run as root.  It will never _require_ root access on your desktop machine - which is the only place it needs to be installed.

It could however need root access when communicating tasks to remote hosts, and in that event it will resort to your `~/.secrets` file.

All your passwords should be stored in `~/.secrets`, which is gnugp-encrypted with your user's public key; site will ask `gpg-agent` (or you) whenever it needs access to it.

You can store any password you like in there, even remote host sudo passwords.

---

###### TAGS: `abstraction`, `automation`, `reporting`, `verifiability`, `standards`, `monitoring`, `unit-testing`, `bash`, `ssh`, `tmux`, `netgroup`, `hosts`, `users`, `ldap`, `mongo`, `softlayer`, `gnupg`, `remote-execution`, `sudo`, `tmux`, `shell-scripting`, `traceback`, `ldif`
