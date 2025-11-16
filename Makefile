## help:                             displays this help
.PHONY: help
help: Makefile
	@sed -n 's/^## \?//p' $<

## dev:                              starts the development server
dev:
	poetry run mkdocs serve

## build-failures:                    shows failures from latest GitHub Actions build
build-failures:
	@gh run list --repo mattflo/prompt-works-blog --workflow=deploy.yml --limit 1 --json databaseId,conclusion --jq '.[0] | select(.conclusion == "failure") | .databaseId' | xargs -I {} gh run view {} --repo mattflo/prompt-works-blog --log || echo "No failed builds found"

## test-build:                        runs GitHub Actions workflow locally using act
test-build:
	act push --container-architecture linux/amd64 -j deploy