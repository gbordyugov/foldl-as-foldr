all: folds.html

folds.html: README.md Makefile
	pandoc -f markdown+lhs -s --webtex README.md -o folds.html
