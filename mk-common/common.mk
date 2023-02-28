scriptdir := $(CURDIR)/../scripts

all: $(answers)

.NOTINTERMEDIATE: input_%.txt
input_%.txt:
	$(scriptdir)/get-aoc-input $(shell basename $(CURDIR)) $(shell echo $* | sed 's/^0*//') > $@

.PHONY: clean
clean:
	$(RM) $(answers)
