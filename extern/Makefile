EXTERN := shflags shunit2 vimpager
SHFLAGS := shflags-1.0.3
SHUNIT2 := shunit2-2.1.6
VIMPAGER := vimpager.git

WGET := $(shell which wget)
ifeq (${WGET},)
CURL := $(shell which curl)
DLA := ${CURL} -s
else
DLA := ${WGET} -q -O-
endif

ifneq (${DLA},)
ALL: ${EXTERN}
	@echo "Building extern..."
#. shflags -={
shflags: ${SHFLAGS}
	@ln -sf $</src/$@ $@
${SHFLAGS}: ${SHFLAGS}.tgz
	@echo "Untarring $<..."
	@tar xzf $<
	@touch $@
${SHFLAGS}.tgz:
	@echo "Downloading $@..."
	${DLA} http://shflags.googlecode.com/files/$@ > $@
#. }=-
#. shunit2 -={
shunit2: ${SHUNIT2}
	@ln -sf $</src/$@ $@
${SHUNIT2}: ${SHUNIT2}.tgz
	@echo "Untarring $<..."
	@tar xzf $<
	@touch $@
${SHUNIT2}.tgz:
	@echo "Downloading $@..."
	@${DLA} http://shunit2.googlecode.com/files/$@ > $@
#. }=-
#. vimpager -={
vimpager: vimpager.git
	@ln -sf $</vimpager vimpager
	@ln -sf $</vimcat vimcat
vimpager.git:
	@echo "Downloading $@..."
	@git clone http://github.com/rkitover/vimpager .$@ && mv .$@ $@ || rm -rf .$@
#. }=-

clean:
	@echo "Cleaning extern..."
	@rm -rf shflags ${SHFLAGS}
	@rm -rf shunit2 ${SHUNIT2}
	@rm -rf vimpager ${VIMPAGER}

.PHONY: ALL clean

else
$(warning "No appropriate downloaded found in your PATH.")
endif
