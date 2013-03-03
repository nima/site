EXTERN := shflags shunit2
SHFLAGS := shflags-1.0.3
SHUNIT2 := shunit2-2.1.6

WGET := $(shell which wget)
DLA := ${WGET} -q -O-
ifeq (${DLA},)
CURL := $(shell which curl)
DLA := ${CURL} -s
endif

ifneq (${DLA},)
ALL: ${EXTERN}
	@echo "Building extern..."
#. shflags -={
shflags: ${SHFLAGS}
	@ln -s $</src/$@ $@
${SHFLAGS}: ${SHFLAGS}.tgz
	@echo "Untarring $<..."
	@tar xzf $<
	@touch $@
${SHFLAGS}.tgz:
	@echo "Downloading $@..."
	@${DLA} http://shflags.googlecode.com/files/$@ > $@
#. }=-
#. shunit2 -={
shunit2: ${SHUNIT2}
	@ln -s $</src/$@ $@
${SHUNIT2}: ${SHUNIT2}.tgz
	@echo "Untarring $<..."
	@tar xzf $<
	@touch $@
${SHUNIT2}.tgz:
	@echo "Downloading $@..."
	@${DLA} http://shunit2.googlecode.com/files/$@ > $@
#. }=-

clean:
	@echo "Cleaning extern..."
	@rm -rf shflags ${SHFLAGS}
	@rm -rf shunit2 ${SHUNIT2}
.PHONY: ALL clean

else
$(warning "No appropriate downloaded found in your PATH.")
endif
