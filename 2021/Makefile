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

srcs := $(wildcard *.py)
answers := $(subst puzzle,answer,$(srcs:.py=.txt))

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: puzzle_%.py input_%.txt
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
	$(ruff) --fix-only $(srcs)
	$(black) $(srcs)

.PHONY: distclean
distclean: clean
	$(RM) -r .mypy_cache
	$(ruff) clean
