MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

NIM ?= nim

ext := .nim
srcs := $(wildcard puzzle_*$(ext))
answers := $(subst puzzle,answer,$(srcs:$(ext)=.txt))

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: puzzle_% input_%.txt
	./$< < $(filter-out $<, $^) | tee $@

.NOTINTERMEDIATE: puzzle_%
puzzle_%: puzzle_%$(ext) nim.cfg
	$(NIM) c $<

.PHONY: format
format:
	nimpretty $(srcs)

.PHONY: distclean
distclean: clean
	$(RM) $(basename $(srcs))
