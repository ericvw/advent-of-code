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
	golangci-lint run $(srcs)

.PHONY: format
format:
	golangci-lint fmt $(srcs)

.PHONY: distclean
distclean: clean
	$(RM) $(basename $(srcs))
