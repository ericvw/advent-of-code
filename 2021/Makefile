MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

PYTHON ?= python

black := $(PYTHON) -m black
flake8 := $(PYTHON) -m flake8
isort := $(PYTHON) -m isort
mypy := $(PYTHON) -m mypy

srcs := $(wildcard *.py)
answers := $(subst puzzle,answer,$(srcs:.py=.txt))

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: puzzle_%.py input_%.txt
	$(PYTHON) ./$< < $(filter-out $<, $^) | tee $@

.PHONY: lint
lint: lint-format lint-flake8 lint-types lint-imports

.PHONY: lint-flake8
lint-flake8:
	$(flake8) $(srcs)

.PHONY: lint-format
lint-format:
	$(black) --check --diff $(srcs)

.PHONY: lint-imports
lint-imports:
	$(isort) --check-only $(srcs)

.PHONY: lint-types
lint-types:
	$(mypy) $(srcs)

.PHONY: format
format:
	$(isort) $(srcs)
	$(black) $(srcs)

.PHONY: distclean
distclean: clean
	$(RM) -r .mypy_cache
