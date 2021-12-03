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

pysrcs :=

.PHONY: all
all:

.PHONY: lint
lint: lint-format lint-flake8 lint-types lint-imports


.PHONY: lint-flake8
lint-flake8:
	$(flake8) $(pysrcs)

.PHONY: lint-format
lint-format:
	$(black) --check --diff $(pysrcs)

.PHONY: lint-imports
lint-imports:
	$(isort) --check-only $(pysrcs)

.PHONY: lint-types
lint-types:
	$(mypy) $(pysrcs)

.PHONY: format
format: format-python

.PHONY: format-python
format-python:
	$(isort) $(pysrcs)
	$(black) $(pysrcs)

.PHONY: clean
clean:

.PHONY: distclean
distclean: clean
