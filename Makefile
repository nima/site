export MAKEFLAGS := --no-print-directory --warn-undefined-variables

BIN_PY27  := python2.7
BIN_VENV  := virtualenv
BIN_RBENV := rbenv
REQUIRED  := ${BIN_PY27} ${BIN_VENV} ${BIN_RBENV}
EXTERN_D  := ${HOME}/.site/var
export BIN_PY27 BIN_VENV BIN_RBENV
export EXTERN_D

.DEFAULT: help

#. Site Bootstrap -={
#. Installation Status Check -={
#. Additional python modules that you want installed - this should be kept as
#. small as possible, and each site module should have it's own set of modules
#. defined via xplm.
VENV_PKGS :=
export VENV_PKGS

RBENV_ROOT=${EXTERN_D}/rbenv
RBENV_VERSION := 2.1.1
RBENV_GEMSETS="${RBENV_ROOT}/gemset global"
export RBENV_ROOT RBENV_VERSION RBENV_GEMSETS

ifeq ($(wildcard .install),)
STATUS := "UNINSTALLED"
else
STATUS := "INSTALLED"
endif
#. }=-
#. Usage -={
.PHONY: help
help: require
	@echo "Current status  : ${STATUS}"
	@echo "Current profile : $(shell bin/activate)"
	@echo
	@echo "Usage:"
	@echo "    $(MAKE) install"
	@echo "    $(MAKE) uninstall"
#. }=-
#. REQUIRED Check -={
.PHONY: require
require:; @$(foreach req,$(REQUIRED:%.required=%),printf ${req}...;which ${req} || (echo FAIL && exit 1);)
#. }=-
#. Installation -={
.PHONY: install sanity
sanity:; @test ! -f .install
install: require sanity .install
	@echo "Installation complete!"

.install:
	@printf "Preparing ~/.site..."
	@mkdir -p $(HOME)/.site
	@ln -s ${HOME}/.site/profiles.d/ACTIVE/lib ${HOME}/.site/lib
	@ln -s ${HOME}/.site/profiles.d/ACTIVE/etc ${HOME}/.site/etc
	@ln -s ${HOME}/.site/profiles.d/ACTIVE/module ${HOME}/.site/module
	@ln -s ${HOME}/.site/profiles.d/ACTIVE/libexec ${HOME}/.site/libexec
	@echo "DONE"
	@printf "Setting up initial profile...\n"
	@ln -sf $(PWD) $(HOME)/.site/.scm
	@bin/activate DEFAULT
	@
	@printf "Preparing ${EXTERN_D}..."
	@mkdir -p /var/tmp/site/var
	@mkdir -p /var/tmp/site/var/cache
	@mkdir -p /var/tmp/site/var/run
	@mkdir -p /var/tmp/site/var/log
	@mkdir -p /var/tmp/site/var/tmp
	@mkdir -p /var/tmp/site/var/lib
	@ln -sf /var/tmp/site/var ${EXTERN_D}
	@ln -sf $(PWD)/share/extern.makefile ${EXTERN_D}/Makefile
	@echo "DONE"
	@
	@printf "Populating ${EXTERN_D}...\n"
	@$(MAKE) -f $(PWD)/share/extern.makefile -C ${EXTERN_D} install
	@
	@printf "Installing symbolic links in $(HOME)/bin/..."
	@mkdir -p $(HOME)/.site/bin
	@ln -sf $(PWD)/bin/site $(HOME)/.site/bin/site
	@ln -sf $(PWD)/bin/ssh $(HOME)/.site/bin/ssm
	@ln -sf $(PWD)/bin/ssh $(HOME)/.site/bin/ssp
	@ln -sf $(PWD)/bin/activate $(HOME)/.site/bin/activate
	@mkdir -p $(HOME)/bin
	@ln -sf $(HOME)/.site/bin/site $(HOME)/bin/site
	@echo "DONE"
	@
	@test -f ~/.siterc || touch .initialize
	@test ! -f .initialize || printf "Installing default ~/.siterc..."
	@test ! -f .initialize || cp share/examples/siterc.eg ${HOME}/.siterc
	@test ! -f .initialize || echo "DONE"
	@rm -f .initialize
	@
	@touch .install
#. }=-
#. Uninstallation -={
.PHONY: unsanity unsanity
unsanity:; @test -f .install
uninstall: unsanity
	@$(MAKE) -f $(PWD)/share/extern.makefile -C ${EXTERN_D} uninstall
	@
	find lib/libpy -name '*.pyc' -exec rm -f {} \;
	find lib/libpy -name '*.pyo' -exec rm -f {} \;
	@
	-rm $(HOME)/.site/lib
	-rm $(HOME)/.site/etc
	-rm $(HOME)/.site/module
	-rm $(HOME)/.site/libexec
	-rm $(HOME)/.site/var
	@
	-rm $(HOME)/bin/site
	-rm $(HOME)/.site/bin/site
	-rm $(HOME)/.site/bin/ssm
	-rm $(HOME)/.site/bin/ssp
	-rm $(HOME)/.site/bin/activate
	-rmdir $(HOME)/.site/bin
	@
	-rm $(HOME)/.site/.scm
	@-rm .install
	@#rmdir $(HOME)/.site
	@
	@echo "Uninstallation complete!"
purge:
	@test ! -d ${EXTERN_D} || $(MAKE) -f $(PWD)/share/extern.makefile -C ${EXTERN_D} purge
	test ! -d ~/.site || find ~/.site -type l -exec rm -f {} \;
	@#test ! -d ~/.site || find ~/.site -depth -type d -empty -exec rmdir {} \;
	rm -rf /var/tmp/site/
	rm -f .install
#. }=-
#. Devel -={
travis:
	@travis sync
	@while true; do clear; travis branches; sleep 10; done
#. }=-
#. }=-
