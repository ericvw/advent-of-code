MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

CARGO ?= cargo
PROFILE ?= release

ext := .rs
srcdir := src/bin
srcs := $(wildcard $(srcdir)/puzzle_*$(ext))
answers := $(subst puzzle,answer,$(patsubst %$(ext),%.txt, $(notdir $(srcs))))

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: $(srcdir)/puzzle_%$(ext) input_%.txt
	$(CARGO) run --profile $(PROFILE) --bin $(basename $(notdir $<)) < $(filter-out $<, $^) | tee $@

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
