export MAKEFLAGS := --no-print-directory --warn-undefined-variables

#. Site Bootstrap -={
#. PROFILE Check -={
ifeq (${PROFILE},)
$(error PROFILE is not set)
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
help:
	@echo "Current status  : ${STATUS}"
	@echo "Current profile : ${PROFILE}"
	@echo
	@echo "Usage:"
	@echo "    $(MAKE) install"
	@echo "    $(MAKE) uninstall"
#. }=-
#. Installation -={
.PHONY: install sanity
sanity:; @test ! -f .install
install: sanity .install
	@echo "Installation complete!"
	@echo
	@echo "You can now bootstrap your installation by setting up your profile:"
	@echo "    cp share/examples/siterc.eg ~/.siterc"
	@echo "    mkdir -p profile/${PROFILE}/etc"
	@echo "    cp share/examples/site.conf.eg profile/${PROFILE}/etc/site.conf"
	@echo
	@echo "Copy the template module..."
	@echo "    mkdir -p profile/${PROFILE}/module"
	@echo "    cp share/module/template profile/${PROFILE}/mymod"
	@echo
	@echo "Try out your new module..."
	@echo "    site mymod"
	@echo
	@echo "Finally, commit your new profile to your own git repo:"
	@echo "    cd profile/${PROFILE}/"
	@echo "    git init"
	@echo

.install:
	@mkdir -p $(HOME)/.site
	@
	@$(MAKE) -C extern install
	ln -sf $(PWD)/extern $(HOME)/.site/extern
	ln -sf $(PWD)/lib $(HOME)/.site/lib
	ln -sf $(PWD)/module $(HOME)/.site/module
	ln -sf $(PWD)/libexec $(HOME)/.site/libexec
	ln -sf $(PWD)/share $(HOME)/.site/share
	ln -sf $(PWD)/profile $(HOME)/.site/profile
	@
	@mkdir -p /var/tmp/site/
	ln -sf /var/tmp/site/ $(HOME)/.site/log
	@
	mkdir -p $(HOME)/bin
	ln -sf $(PWD)/bin/site $(HOME)/bin/site
	ln -sf $(PWD)/bin/ssh $(HOME)/bin/ssm
	ln -sf $(PWD)/bin/ssh $(HOME)/bin/ssp
	@
	touch .install
#. }=-
#. Uninstallation -={
.PHONY: unsanity unsanity
unsanity:; @test -f .install
uninstall: unsanity
	@$(MAKE) -C extern uninstall
	@
	find lib/libpy -name '*.pyc' -exec rm -f {} \;
	find lib/libpy -name '*.pyo' -exec rm -f {} \;
	@
	-rm $(HOME)/.site/extern
	-rm $(HOME)/.site/lib
	-rm $(HOME)/.site/module
	-rm $(HOME)/.site/libexec
	-rm $(HOME)/.site/var
	-rm $(HOME)/.site/log
	-rm $(HOME)/bin/site
	-rm $(HOME)/bin/ssm
	-rm $(HOME)/bin/ssp
	@
	@-rm .install
	rmdir $(HOME)/.site
	@
	@echo "Uninstallation complete!"
purge:
	@$(MAKE) -C extern purge
	test ! -d ~/.site || find ~/.site -type l -exec rm -f {} \;
	test ! -d ~/.site || find ~/.site -depth -type d -empty -exec rmdir {} \;
	rm -rf /var/tmp/site/
	rm -f .install
#. }=-

#. }=-
