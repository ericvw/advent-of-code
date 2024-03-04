MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

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

intcode_deps := $(wildcard $(srcdir)/*.rs)

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: $(outputdir)/puzzle_% input_%.txt
	$(CARGO) run --profile $(PROFILE) --bin $(basename $(notdir $<)) < $(filter-out $<, $^) | tee $@

.NOTINTERMEDIATE: $(outputdir)/puzzle_%
$(outputdir)/puzzle_%: $(srcbindir)/puzzle_%$(ext)
	$(CARGO) build --profile $(PROFILE) --bin $(basename $(notdir $<))

$(outputdir)/puzzle_02: $(intcode_deps)

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

.PHONY: distclean
distclean: clean
	$(CARGO) clean
	$(RM) Cargo.lock
