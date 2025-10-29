## help:                             displays this help
.PHONY: help
help: Makefile
	@sed -n 's/^## \?//p' $<

## dev:                              starts the development server
dev:
	poetry run mkdocs serve