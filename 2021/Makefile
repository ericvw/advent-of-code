MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

PYTHON ?= python

black := $(PYTHON) -m black
mypy := $(PYTHON) -m mypy
ruff := $(PYTHON) -m ruff

ext := .py
srcs := $(wildcard puzzle_*$(ext))
answers := $(subst puzzle,answer,$(srcs:$(ext)=.txt))

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: puzzle_%$(ext) input_%.txt
	$(PYTHON) ./$< < $(filter-out $<, $^) | tee $@

.PHONY: lint
lint: lint-types lint-ruff lint-format

.PHONY: lint-ruff
lint-ruff:
	$(ruff) check $(srcs)

.PHONY: lint-format
lint-format:
	$(black) --check --diff $(srcs)

.PHONY: lint-types
lint-types:
	$(mypy) $(srcs)

.PHONY: format
format:
	$(ruff) check --fix-only $(srcs)
	$(black) $(srcs)

.PHONY: distclean
distclean: clean
	$(RM) -r .mypy_cache
	$(ruff) clean
