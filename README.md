# OVERVIEW
**MISSION STATEMENT**: _To simplify group scripting, reporting and automation tasks for large teams of system engineers_

Site is written for system administrators, system engineers, devOps, or automation engineers.  It is a superset of bash, and structured to scale with your scripting requirements.

Site is broken up into two main chunks:

1. The bits that we write: the *site engine* (`lib/libsite`), and *core modules* `module/*`
2. The bits that you write: *user modules* (`profile/${PROFILE}/module/*`)

You can configure site in two places:

1. `profile/${PROFILE}/etc/site.conf` - configuration specific to *your organization*
2. `~/.siterc` - configuration specific to *you*


# REQUIREMENTS

1. Core Requirements
    * You need bash v4.0+
    * You need gnu grep v2.0+ (probably)
2. Additional Requirements
    * The site modules will themselves check for any python, ruby, or perl module you need for that particular module.


# INSTALLATION

1. Clone It

    ```bash
    cd ~/
    git clone https://github.com/nima/site.git
    cd site
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
Scripts change over time, and so unit-testing is as relevant to systems scripts as it is to any piece of software.  Site comes with a flexible unit-testing module. This module reads everything it needs to know about every function test from a unit-testing configuration file, and warns you for functions that are missing unit-test data.

```
% site unit test
```

## Security Measures
Site doesn't expect to be run as root; in fact it should _never_ be run as root.  It will never _require_ root access on your desktop machine - which is the only place it needs to be installed.

It could however need root access when communicating tasks to remote hosts, and in that event it will resort to your `~/.secrets` file.

All your passwords should be stored in `~/.secrets`, which is gnugp-encrypted with your user's public key; site will ask `gpg-agent` (or you) whenever it needs access to it.

You can store any password you like in there, even remote host sudo passwords.
