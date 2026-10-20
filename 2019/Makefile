CARGO ?= cargo
PROFILE ?= release

profiledir := release
ifneq ($(PROFILE),release)
profiledir := debug
endif
outputdir := target/$(profiledir)

ext := .rs
srcdir := src
srcbindir := $(srcdir)/bin
srcs := $(wildcard $(srcbindir)/puzzle_*$(ext))
answers := $(subst puzzle,answer,$(patsubst %$(ext),%.txt, $(notdir $(srcs))))

library_deps := $(wildcard $(srcdir)/*.rs)

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: $(outputdir)/puzzle_% input_%.txt
	$(CARGO) run --profile $(PROFILE) --bin $(basename $(notdir $<)) < $(filter-out $<, $^) | tee $@

.NOTINTERMEDIATE: $(outputdir)/puzzle_%
$(outputdir)/puzzle_%: $(srcbindir)/puzzle_%$(ext) $(library_deps)
	$(CARGO) build --profile $(PROFILE) --bin $(basename $(notdir $<))

.PHONY: lint
lint: lint-code lint-format

.PHONY: lint-code
lint-code:
	$(CARGO) clippy

.PHONY: lint-format
lint-format:
	$(CARGO) fmt --check

.PHONY: format
format:
	$(CARGO) clippy --fix --allow-dirty
	$(CARGO) fmt

distclean:
	$(CARGO) clean
	$(RM) Cargo.lock
