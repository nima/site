#. -={
#. Web Getter -={
WGET := $(shell which wget)
ifeq (${WGET},)
CURL := $(shell which curl)
DLA := ${CURL} -s
else
DLA := ${WGET} -q -O-
endif
ifneq (${DLA},)
#. }=-

flycatcher:
	@echo "Do not run make here unless you know what you're doing."

EXTERN_XPLM := rbenv plenv pyenv

EXTERN := shflags shunit2
EXTERN += ${EXTERN_XPLM}
EXTERN += vimpager jsontool

LIBSH   := lib/libsh
LIBRB   := lib/librb
LIBPY   := lib/libpy
LIBPL   := lib/libpl

#. Installation -={
.PHONY: prepare install $(EXTERN:%=%.install)
install: .install; @echo "Installation (extern) complete!"
.install: prepare $(EXTERN:%=%.install); @touch .install

prepare:
	@printf "Preparing extern build..."
	@mkdir -p libexec
	@mkdir -p ${LIBSH} ${LIBRB} ${LIBPY} ${LIBPL}
	@mkdir -p src scm
	@echo "DONE"
#. }=-
#. Uninstallation -={
.PHONY: unprepare uninstall $(EXTERN:%=%.uninstall)
unprepare:
	@printf "Unpreparing extern build..."
	@find ${LIBPY} -name '*.pyc' -exec rm -f {} \;
	@find ${LIBPY} -name '*.pyo' -exec rm -f {} \;
	@rmdir ${LIBSH} ${LIBRB} ${LIBPY} ${LIBPL} lib
	@rmdir libexec
	@echo "DONE"

uninstall: $(EXTERN:%=%.uninstall) unprepare
	@rm -f .install
	@echo "Uninstallation (extern) complete!"

purge: $(EXTERN:%=%.purge)
	rm -rf src
	rm -rf scm
	rm -rf lib
	rm -rf libexec
	rm -f .install
#. }=-

include ${VCS_D}/lib/xplm.conf
#. rbenv for ruby -={
.PHONY: rbenv rbenv.install rbenv.uninstall rbenv.purge rbenv.plugins
RBENV_ROOT=${EXTERN_D}/rbenv
export RBENV_ROOT RBENV_VERSION

rbenv.install: rbenv
rbenv.uninstall:
	@rm -f libexec/rbenv
rbenv.purge: rbenv.uninstall
	@rm -rf rbenv
	@rm -rf scm/rbenv.git
	@rm -rf scm/ruby-build.git

rbenv: libexec/rbenv rbenv.plugins
libexec/rbenv: scm/rbenv.git
	@printf "Installing $(@F) executable..."
	@ln -s ${EXTERN_D}/$</bin/${@F} $@
	@echo DONE
scm/rbenv.git:
	@printf "Cloning $(@F)..."
	@git clone -q https://github.com/sstephenson/rbenv.git $@
	@echo DONE

rbenv.plugins: rbenv/plugins rbenv/plugins/ruby-build
rbenv/plugins:
	@mkdir -p $@
	@$(foreach m,$(wildcard scm/rbenv.git/plugins/*),ln -s ${EXTERN_D}/$m $@/$(notdir $m);)
rbenv/plugins/ruby-build: scm/ruby-build.git; @ln -s ${EXTERN_D}/$< $@
scm/ruby-build.git:
	@printf "Cloning $(@F)..."
	@git clone -q https://github.com/sstephenson/ruby-build.git $@
	@echo DONE
#. }=-
#. pyenv for python -={
.PHONY: pyenv pyenv.install pyenv.uninstall pyenv.purge pyenv.plugins
PYENV_ROOT=${EXTERN_D}/pyenv
export PYENV_ROOT PYENV_VERSION

pyenv.install: pyenv
pyenv.uninstall:
	@rm -f libexec/pyenv
pyenv.purge: pyenv.uninstall
	@rm -rf pyenv
	@rm -rf scm/pyenv.git
	@rm -rf scm/python-build.git

pyenv: libexec/pyenv pyenv.plugins
libexec/pyenv: scm/pyenv.git
	@printf "Installing $(@F) executable..."
	@ln -s ${EXTERN_D}/$</bin/${@F} $@
	@echo DONE
scm/pyenv.git:
	@printf "Cloning $(@F)..."
	@git clone -q https://github.com/yyuu/$(@F) $@
	@echo DONE

pyenv.plugins: pyenv/plugins pyenv/plugins/pyenv-virtualenv
pyenv/plugins:
	@mkdir -p $@
	@$(foreach m,$(wildcard scm/pyenv.git/plugins/*),ln -s ${EXTERN_D}/$m $@/$(notdir $m);)
pyenv/plugins/pyenv-virtualenv: scm/pyenv-virtualenv.git; @ln -s ${EXTERN_D}/$< $@
scm/pyenv-virtualenv.git:
	@printf "Cloning $(@F)..."
	@git clone -q https://github.com/yyuu/$(@F) $@
	@echo DONE
#. }=-
#. plenv for perl -={
.PHONY: plenv plenv.install plenv.uninstall plenv.purge plenv.plugins
PLENV_ROOT=${EXTERN_D}/plenv
export PLENV_ROOT PLENV_VERSION

plenv.install: plenv
plenv.uninstall:
	@rm -f libexec/plenv
plenv.purge: plenv.uninstall
	@rm -rf plenv
	@rm -rf scm/plenv.git
	@rm -rf scm/perl-build.git

plenv: libexec/plenv plenv.plugins
libexec/plenv: scm/plenv.git
	@printf "Installing $(@F) executable..."
	@ln -s ${EXTERN_D}/$</bin/${@F} $@
	@echo DONE
scm/plenv.git:
	@printf "Cloning $(@F)..."
	@git clone -q https://github.com/tokuhirom/$(@F) $@
	@echo DONE

plenv.plugins: plenv/plugins plenv/plugins/perl-build
plenv/plugins:
	@mkdir -p $@
	@$(foreach m,$(wildcard scm/plenv.git/plugins/*),ln -s ${EXTERN_D}/$m $@/$(notdir $m);)
plenv/plugins/perl-build: scm/perl-build.git; @ln -s ${EXTERN_D}/$< $@
scm/perl-build.git:
	@printf "Cloning $(@F)..."
	@git clone -q git://github.com/tokuhirom/Perl-Build.git $@
	@echo DONE
#. }=-

#. shflags -={
TGZ_SHFLAGS := src/shflags-1.0.3.tgz
SRC_SHFLAGS := $(TGZ_SHFLAGS:.tgz=)
shflags.purge: shflags.uninstall
	@-rm -r ${TGZ_SHFLAGS}
shflags.uninstall:
	@-rm ${LIBSH}/shflags
	@-rm -r ${SRC_SHFLAGS}
shflags.install: ${LIBSH}/shflags
${LIBSH}/shflags: ${SRC_SHFLAGS}
	@ln -sf ${HOME}/.site/var/$</src/shflags $@
${SRC_SHFLAGS}: ${TGZ_SHFLAGS}
	@printf "Untarring $< into $(@D)..."
	@tar -C $(@D) -xzf $<
	@touch $@
	@echo "DONE"
${TGZ_SHFLAGS}:
	@printf "Downloading $@..."
	@${DLA} http://shflags.googlecode.com/files/$(@F) > $@
	@echo "DONE"
#. }=-
#. shunit2 -={
TGZ_SHUNIT2 := src/shunit2-2.1.6.tgz
SRC_SHUNIT2 := $(TGZ_SHUNIT2:.tgz=)
shunit2.purge: shunit2.uninstall
	@-rm -r ${TGZ_SHUNIT2}
shunit2.uninstall:
	@-rm libexec/shunit2
	@-rm -r ${SRC_SHUNIT2}
shunit2.install: libexec/shunit2
libexec/shunit2: ${SRC_SHUNIT2}
	@ln -sf ${HOME}/.site/var/$</src/shunit2 $@
${SRC_SHUNIT2}: ${TGZ_SHUNIT2}
	@printf "Untarring $< into $(@D)..."
	@tar -C $(@D) -xzf $<
	@touch $@
	@echo "DONE"
${TGZ_SHUNIT2}:
	@printf "Downloading $@..."
	@${DLA} http://shunit2.googlecode.com/files/$(@F) > $@
	@echo "DONE"
#. }=-
#. vimpager -={
.PHONY: vimpager.install vimpager.uninstall vimpager.purge
vimpager.purge: vimpager.uninstall
	-rm -rf scm/vimpager.git
vimpager.uninstall:
	@-rm libexec/vimpager
	@-rm libexec/vimcat
vimpager.install: scm/vimpager.git
	@ln -sf $(CURDIR)/$</vimpager libexec/vimpager
	@ln -sf $(CURDIR)/$</vimcat libexec/vimcat
scm/vimpager.git:
	@echo "Cloning $(@F)..."
	@git clone -q http://github.com/rkitover/vimpager $@
#. }=-
#. pyobjpath -={
pyobjpath.uninstall:
	@-rm ${LIBPY}/pyobjpath/core
	@-rm ${LIBPY}/pyobjpath/utils
	@-rm ${LIBPY}/pyobjpath/__init__.py
	@-rmdir ${LIBPY}/pyobjpath/
pyobjpath.install: scm/pyobjpath.git
	@mkdir ${LIBPY}/pyobjpath
	@touch ${LIBPY}/pyobjpath/__init__.py
	@ln -sf $(CURDIR)/$</ObjectPathPy/core ${LIBPY}/pyobjpath/core
	@ln -sf $(CURDIR)/$</ObjectPathPy/utils ${LIBPY}/pyobjpath/utils
scm/pyobjpath.git:
	@echo "Cloning $@..."
	@git clone -q https://github.com/adriank/ObjectPath.git $@
#. }=-
#. jsontool -={
.PHONY: jsontool.install jsontool.uninstall jsontool.purge
jsontool.purgel: jsontool.uninstall; @-rm -rf libexec/jsontool
jsontool.uninstall:; @-rm libexec/jsontool
jsontool.install: libexec/jsontool
libexec/jsontool: src/jsontool
	@printf "Installing jsontool..."
	@install -m 755 $< $@
	@echo "DONE"
src/jsontool:
	@printf "Downloading jsontool..."
	@${DLA} https://github.com/trentm/json/raw/master/lib/jsontool.js > $@
	@echo "DONE"
#. }=-

#. -={
else
$(warning "No appropriate downloaded found in your PATH.")
endif
#. }=-
#. }=-
