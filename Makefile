.PHONY: publish

all: publish

publish: publish.el
	emacs --quick --script publish.el
