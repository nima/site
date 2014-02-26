export MAKEFLAGS := --no-print-directory --warn-undefined-variables

BIN_PY27 := python2.7
BIN_VENV := virtualenv
REQUIRED := ${BIN_PY27} ${BIN_VENV}
EXTERN_D   := ~/.site/var
export BIN_PY27 BIN_VENV

.DEFAULT: help

#. Site Bootstrap -={
#. SITE_PROFILE Check -={
ifeq (${SITE_PROFILE},)
$(error SITE_PROFILE is not set)
endif
#. }=-
#. Installation Status Check -={
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
	@echo "Current profile : ${SITE_PROFILE}"
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
	@echo "DONE"
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
	@printf "Installing symbolic links in $(HOME)/.site/..."
	@ln -sf $(PWD) $(HOME)/.site/.scm
	@ln -sf $(PWD)/lib $(HOME)/.site/lib
	@ln -sf $(PWD)/profile/${SITE_PROFILE}/etc $(HOME)/.site/etc
	@ln -sf $(PWD)/profile/${SITE_PROFILE}/module $(HOME)/.site/module
	@ln -sf $(PWD)/profile/${SITE_PROFILE}/libexec $(HOME)/.site/libexec
	@echo "DONE"
	@
	@printf "Installing symbolic links in $(HOME)/bin/..."
	@mkdir -p $(HOME)/bin
	@ln -sf $(PWD)/bin/site $(HOME)/bin/site
	@ln -sf $(PWD)/bin/ssh $(HOME)/bin/ssm
	@ln -sf $(PWD)/bin/ssh $(HOME)/bin/ssp
	@echo "DONE"
	@
	@test -d profile/${SITE_PROFILE} || touch .initialize
	@test ! -f .initialize || printf "Populating profile/${SITE_PROFILE}..."
	@test ! -f .initialize || mkdir -p profile/${SITE_PROFILE}/etc
	@test ! -f .initialize || cp share/examples/site.conf.eg profile/${SITE_PROFILE}/etc/site.conf
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
	-rm $(HOME)/bin/ssm
	-rm $(HOME)/bin/ssp
	@
	-rm $(HOME)/.site/.scm
	@-rm .install
	rmdir $(HOME)/.site
	@
	@echo "Uninstallation complete!"
purge:
	@$(MAKE) -f $(PWD)/share/extern.makefile -C ${EXTERN_D} purge
	test ! -d ~/.site || find ~/.site -type l -exec rm -f {} \;
	test ! -d ~/.site || find ~/.site -depth -type d -empty -exec rmdir {} \;
	rm -rf /var/tmp/site/
	rm -f .install
#. }=-
#. Devel -={
travis:
	@travis sync
	@while true; do clear; travis branches; sleep 10; done
#. }=-
#. }=-
