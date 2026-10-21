GO ?= go

ext := .go
srcs := $(wildcard puzzle_*$(ext))
answers := $(subst puzzle,answer,$(srcs:$(ext)=.txt))

include $(CURDIR)/../mk-common/common.mk

answer_%.txt: puzzle_% input_%.txt
	./$< < $(filter-out $<, $^) | tee $@

.NOTINTERMEDIATE: puzzle_%
puzzle_%: puzzle_%$(ext)
	$(GO) build $<

.PHONY: lint
lint: lint-code

.PHONY: lint-code
lint-code:
	for src in $(srcs); do golangci-lint run $$src; done

.PHONY: format
format:
	golangci-lint fmt $(srcs)

distclean:
	$(RM) $(basename $(srcs))
