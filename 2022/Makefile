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

.PHONY: lint
lint: lint-format

.PHONY: lint-format
lint-format:
	for src in $(srcs); do $(NIM) check $$src; done

.PHONY: format
format:
	nimpretty $(srcs)

distclean:
	$(RM) $(basename $(srcs))
