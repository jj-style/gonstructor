PKGS := $(shell go list ./...)
PKGS_WITHOUT_TEST := $(shell go list ./... | grep -v "gonstructor/internal/test")
RELEASE_DIR=dist
REVISION=$(shell git rev-parse --verify HEAD)
INTERNAL_PACKAGE=github.com/jj-style/gonstructor/internal

check: test lint vet fmt-check
check-ci: test vet fmt-check

build4test: clean
	mkdir -p $(RELEASE_DIR)
	go build -ldflags "-X $(INTERNAL_PACKAGE).rev=$(REVISION) -X $(INTERNAL_PACKAGE).ver=TESTING" \
		-o $(RELEASE_DIR)/gonstructor_test cmd/gonstructor/gonstructor.go

gen4test: build4test
	go generate $(PKGS)

test: clean-test-gen gen4test
	go test -v $(PKGS)

clean-test-gen:
	rm -f internal/test/*_gen.go internal/test/**/*_gen.go

lint:
lint:
	golangci-lint run ./...

vet:
	go vet $(PKGS)

fmt-check:
	gofmt -l -s **/*.go | grep [^*][.]go$$; \
	EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then exit 1; fi; \
	goimports -l **/*.go | grep [^*][.]go$$; \
	EXIT_CODE=$$?; \
	if [ $$EXIT_CODE -eq 0 ]; then exit 1; fi \

fmt:
	gofmt -w -s **/*.go
	goimports -w **/*.go

clean:
	rm -rf bin/gonstructor*

