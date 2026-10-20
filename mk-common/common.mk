MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

scriptdir := $(CURDIR)/../scripts

all: $(answers)

.NOTINTERMEDIATE: input_%.txt
input_%.txt:
	$(scriptdir)/get-aoc-input $(shell basename $(CURDIR)) $(shell echo $* | sed 's/^0*//') > $@

.PHONY: clean
clean:
	$(RM) $(answers)

.PHONY: clean-inputs
clean-inputs:
	$(RM) input_*.txt

.PHONY: distclean
distclean: clean clean-inputs
