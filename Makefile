export MAKEFLAGS := --no-print-directory

ifeq (${PROFILE},)
$(error PROFILE is not set)
endif

reinstall: uninstall install

install: extern
	@mkdir -p $(HOME)/.site $(HOME)/bin
	@
	@rm -f $(HOME)/.site/lib
	ln -sf $(PWD)/lib $(HOME)/.site/lib
	@rm -f $(HOME)/.site/etc
	ln -sf $(PWD)/etc $(HOME)/.site/etc
	@rm -f $(HOME)/.site/libexec
	ln -sf $(PWD)/libexec $(HOME)/.site/libexec
	@
	ln -sf $(PWD)/share $(HOME)/.site/share
	@
	ln -sf $(PWD)/bin/site $(HOME)/bin/site
	ln -sf $(PWD)/bin/ssh $(HOME)/bin/ssm
	ln -sf $(PWD)/bin/ssh $(HOME)/bin/ssp
	@echo "Install complete."

extern:
	@make -C $@
	@
	@mkdir -p $(HOME)/.site/extern
	@ln -sf $(PWD)/extern/shflags   $(HOME)/.site/extern/shflags
	@ln -sf $(PWD)/extern/shunit2   $(HOME)/.site/extern/shunit2
	@ln -sf $(PWD)/extern/vimcat    $(HOME)/.site/extern/vimcat
	@ln -sf $(PWD)/extern/vimpager  $(HOME)/.site/extern/vimpager

clean:
	@make -C extern $@

uninstall: clean
	rm -rf $(HOME)/.site
	rm -rf $(HOME)/bin/site
	rm -rf $(HOME)/bin/ssm
	rm -rf $(HOME)/bin/ssp
	@echo "Uninstall complete."

.PHONY: install reinstall uninstall extern clean
