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

EXTERN := shflags shunit2 vimpager pyobjpath jsontool
VENV_PKGS := softlayer paramiko ipaddress

#. Installation -={
.PHONY: prepare install $(EXTERN:%=%.install)
install: .install; @echo "Installation (extern) complete!"
.install: prepare venv.install $(EXTERN:%=%.install); @touch .install

LIBEXEC := libexec
LIBSH   := lib/libsh
LIBRB   := lib/librb
LIBPY   := lib/libpy
prepare:
	@printf "Preparing extern build..."
	@mkdir -p ${LIBEXEC}
	@mkdir -p ${LIBSH} ${LIBPY} ${LIBRB}
	@mkdir -p src scm
	@echo "DONE"
#. }=-
#. Uninstallation -={
.PHONY: unprepare venv.uninstall uninstall $(EXTERN:%=%.uninstall)
unprepare:
	@printf "Unpreparing extern build..."
	find ${LIBPY}
	find ${LIBPY} -name '*.pyc' -exec rm -f {} \;
	find ${LIBPY} -name '*.pyo' -exec rm -f {} \;
	-rmdir ${LIBSH} ${LIBPY} ${LIBRB} lib
	-rmdir ${LIBEXEC}

uninstall: $(EXTERN:%=%.uninstall) unprepare
	@rm -f .install
	@echo "Uninstallation (extern) complete!"

purge:
	rm -rf lib
	rm -rf src
	rm -rf scm
	rm -rf ${LIBEXEC}
	rm -rf venv
	rm -f .install
#. }=-

#. Python VirtualEnv -={
venv:; ${BIN_VENV} -q --clear -p ${BIN_PY27} $@

.PHONY: venv.purge venv.play
.PHONY: venv.install
#$(VENV_PKGS:%=%.venv.install)
.PHONY: venv.uninstall
#$(VENV_PKGS:%=%.venv.uninstall)

#. venv/bin/activate && pip install hg+http://hg.secdev.org/scapy
venv.install: venv $(VENV_PKGS:%=%.venv.install)
%.venv.install:; . venv/bin/activate && pip install -q $(@:.venv.install=)

venv.uninstall: $(VENV_PKGS:%=%.venv.uninstall)
%.venv.uninstall:; . venv/bin/activate && pip uninstall -q -y $(@:.venv.uninstall=)

venv.purge:; rm -rf venv

venv.play:
	@echo "Ctrl-D to exit environment"
	@bash --rcfile venv/bin/activate -i
#. }=-

#. shflags -={
TGZ_SHFLAGS := src/shflags-1.0.3.tgz
SRC_SHFLAGS := $(TGZ_SHFLAGS:.tgz=)
shflags.uninstall:
	-rm ${LIBSH}/shflags
	-rm -r ${SRC_SHFLAGS}
shflags.install: ${LIBSH}/shflags
${LIBSH}/shflags: ${SRC_SHFLAGS}
	@ln -sf $(CURDIR)/$</src/shflags $@
${SRC_SHFLAGS}: ${TGZ_SHFLAGS}
	@echo "Untarring $< into $(@D)..."
	tar -C $(@D) -xzf $<
	@touch $@
${TGZ_SHFLAGS}:
	@echo "Downloading $@..."
	@${DLA} http://shflags.googlecode.com/files/$(@F) > $@
#. }=-
#. shunit2 -={
TGZ_SHUNIT2 := src/shunit2-2.1.6.tgz
SRC_SHUNIT2 := $(TGZ_SHUNIT2:.tgz=)
shunit2.uninstall:
	-rm ${LIBEXEC}/shunit2
	-rm -r ${SRC_SHUNIT2}
shunit2.install: ${LIBEXEC}/shunit2
${LIBEXEC}/shunit2: ${SRC_SHUNIT2}
	@ln -sf $(CURDIR)/$</src/shunit2 $@
${SRC_SHUNIT2}: ${TGZ_SHUNIT2}
	@echo "Untarring $< into $(@D)..."
	tar -C $(@D) -xzf $<
	@touch $@
${TGZ_SHUNIT2}:
	@echo "Downloading $@..."
	@${DLA} http://shunit2.googlecode.com/files/$(@F) > $@
#. }=-
#. vimpager -={
vimpager.uninstall:
	-rm ${LIBEXEC}/vimpager
	-rm ${LIBEXEC}/vimcat
vimpager.install: scm/vimpager.git
	@ln -sf $(CURDIR)/$</vimpager ${LIBEXEC}/vimpager
	@ln -sf $(CURDIR)/$</vimcat ${LIBEXEC}/vimcat
scm/vimpager.git:
	@echo "Cloning $(@F)..."
	@git clone -q http://github.com/rkitover/vimpager $@
#. }=-
#. pyobjpath -={
pyobjpath.uninstall:
	-rm ${LIBPY}/pyobjpath/core
	-rm ${LIBPY}/pyobjpath/utils
	-rm ${LIBPY}/pyobjpath/__init__.py
	-rmdir ${LIBPY}/pyobjpath/
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
jsontool.uninstall:
	-rm ${LIBEXEC}/json
jsontool.install:
	@echo "Downloading jsontool..."
	@${DLA} https://github.com/trentm/json/raw/master/lib/jsontool.js > ${LIBEXEC}/jsontool
	@chmod +x ${LIBEXEC}/jsontool
#. }=-

#. -={
else
$(warning "No appropriate downloaded found in your PATH.")
endif
#. }=-
#. }=-
