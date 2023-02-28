MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

NIM := nim

srcs := $(wildcard puzzle_*.nim)
answers := $(subst puzzle,answer,$(srcs:.nim=.txt))

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: puzzle_% input_%.txt
	./$< < $(filter-out $<, $^) | tee $@

.NOTINTERMEDIATE: puzzle_%
puzzle_%: puzzle_%.nim
	$(NIM) c $<

.PHONY: format
format:
	nimpretty $(srcs)

.PHONY: distclean
distclean: clean
	$(RM) $(basename $(srcs))
