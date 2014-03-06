[![views](https://sourcegraph.com/api/repos/github.com/nima/site/counters/views.png)](https://sourcegraph.com/github.com/nima/site)
[![authors](https://sourcegraph.com/api/repos/github.com/nima/site/badges/authors.png)](https://sourcegraph.com/github.com/nima/site)
[![status](https://sourcegraph.com/api/repos/github.com/nima/site/badges/status.png)](https://sourcegraph.com/github.com/nima/site)

# `gh-pages` README
You are probably looking for this [README](https://github.com/nima/site/blob/gh-pages/README.md), or the corresponding [homepage](http://nima.github.io/site/).

---
# README
Please note that this README doesn't cover what `site` is (that is covered in the [homepage](http://nima.github.io/site/)), but focuses instead on the current status of site development.

## Development Status
<!--
We use moons to illustrate code-complete status.

:new_moon:
:waxing_crescent_moon:
:first_quarter_moon:
:waxing_gibbous_moon:
:full_moon:
:waning_gibbous_moon:
:last_quarter_moon:
:waning_crescent_moon:
:new_moon:
-->

Here are the currently developing/developed site modules:

| Core Module   | Code-Complete           | Description                                                             |
| ------------- | ----------------------- | -------------------------------------------------------------------     |
| unit          | :waning_gibbous_moon:   | Core Unit-Testing module                                                |
| util          | :full_moon:             | Core utilities module                                                   |
| help          | :full_moon:             | Core help module                                                        |
| hgd           | :waning_gibbous_moon:   | Core HGD (Host-Group Directive) module                                  |
| net           | :full_moon:             | Core networking module                                                  |
| gpg           | :full_moon:             | Core GNUPG module                                                       |
| vault         | :full_moon:             | Core vault and secrets management module                                |
| remote        | :waning_gibbous_moon:   | The site remote access/execution module (ssh, ssh/sudo, tmux, etc.)     |
| git           | :full_moon:             | Auxiliary Git helper module                                             |
| dns           | :full_moon:             | Core DNS module                                                         |
| tunnel        | :full_moon:             | Secure shell tunnelling wrapper                                         |
| rb            | :waning_gibbous_moon:   | Interface to Ruby sandbox via `xplm`                                    |
| py            | :waning_gibbous_moon:   | Interface to Python sandbox via `xplm`                                  |
| pl            | :waning_gibbous_moon:   | Interface to Perl sandbox via `xplm` (via `rbenv`, `pyenv`, and `plenv' |
| xplm          | :waning_gibbous_moon:   | Interface to Ruby, Python, and Perl sandboxes                           |
| tutorial      | :waning_crescent_moon:  | The site module aims to serve as a tutorial for new site users          |

And here is their relationship with one-another; i.e., the dependecy graph of the core primary site modules:
![Module Dependencies](https://dl.dropboxusercontent.com/u/68796871/projects/Site/dependencies.png)

The following set of modules are generally only useful under special-circumstances, and so are disabled by default:

| Alpha Modules | Code-Complete           | Description                                                         |
| ------------- | ----------------------- | ------------------------------------------------------------------- |
| ng            | :last_quarter_moon:     | Core Netgroup module                                                |
| ldap          | :last_quarter_moon:     | The site LDAP module                                                |
| mongo         | :new_moon:              | MongoDB helper module                                               |
| softlayer     | :new_moon:              | Softlayer CLI interface                                             |
| pagerduty     | :new_moon:              | PagerDuty CLI interface                                             |

---

# Build Status
Here are the current build statuses of the various GitHub branches of site:

| Branch     | Status |
|------------|--------|
| `master`   | [![Build Status](https://travis-ci.org/nima/site.png?branch=master)](https://travis-ci.org/nima/site/branches) |
| `develop`  | [![Build Status](https://travis-ci.org/nima/site.png?branch=develop)](https://travis-ci.org/nima/site/branches) |
