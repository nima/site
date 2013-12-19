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
	@echo "Usage:"
	@echo "    $(MAKE) install"
	@echo "    $(MAKE) uninstall"
	@echo "Current status: ${STATUS}"
#. }=-
#. Installation -={
.PHONY: install sanity
sanity:; @test ! -f .install
install: sanity .install; @echo "Installation complete!"
.install:
	@mkdir -p $(HOME)/.site
	@
	@$(MAKE) -C extern install
	ln -sf $(PWD)/extern $(HOME)/.site/extern
	ln -sf $(PWD)/lib $(HOME)/.site/lib
	ln -sf $(PWD)/module $(HOME)/.site/module
	ln -sf $(PWD)/libexec $(HOME)/.site/libexec
	ln -sf $(PWD)/profile $(HOME)/.site/profile
	ln -sf $(PWD)/share $(HOME)/.site/share
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
	-rm $(HOME)/.site/profile
	-rm $(HOME)/.site/share
	@
	-rm $(HOME)/bin/site
	-rm $(HOME)/bin/ssm
	-rm $(HOME)/bin/ssp
	@
	-rm .install
	rmdir $(HOME)/.site
	@
	@echo "Uninstallation complete!"
purge:
	@$(MAKE) -C extern purge
	find ~/.site -type l -exec rm -f {} \;
	rm -f .install
#. }=-

#. }=-
