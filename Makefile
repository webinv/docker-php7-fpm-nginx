BUILD_NAME = webinventions/php7-fpm-nginx
BUILD_VERSION := $(shell date +%Y%m%d-%H%M%S)
BUILD_ARGS ?= --no-cache

ifeq ($(shell uname -s),Darwin)
XARGS_OPTS =
else
XARGS_OPTS = -r
endif

.PHONY: clean dist-clean image commit
.IGNORE: dist-clean
.DEFAULT: image

login:
	docker login 

image:
	docker build $(BUILD_ARGS) -t "$(BUILD_NAME):build-v$(BUILD_VERSION)" $(CURDIR)/.
	docker tag "$(BUILD_NAME):build-v$(BUILD_VERSION)" "$(BUILD_NAME):latest"

bash: image
	docker run -it "$(BUILD_NAME):build-v$(BUILD_VERSION)" bash

commit: image
	docker tag "$(BUILD_NAME):build-v$(BUILD_VERSION)" "$(BUILD_NAME):build-v$(BUILD_VERSION)"
	docker tag "$(BUILD_NAME):build-v$(BUILD_VERSION)" "$(BUILD_NAME):latest"

	docker push "$(BUILD_NAME):build-v$(BUILD_VERSION)"
	docker push "$(BUILD_NAME):latest"

dist-clean:
	- docker images "$(BUILD_NAME)" -q | xargs $(XARGS_OPTS) docker rmi