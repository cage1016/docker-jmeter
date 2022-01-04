.PHONY: run-x86
run-x86: ## run x86 jmeter test
	@echo "Running x86 jmeter test"
	./jmeter.sh -i ghcr.io/cage1016/jmeter:5.4.1 -f ap.jmx -t ap -l OUTPUT_FOLDER=$(PWD)/ap,TARGET_HOST=localhost,TARGET_PORT=8080,THREADS=10,RAMD_UP=10,DURATION=20

.PHONY: run-s390
run-s390x: ## run-s390 jmeter test
	@echo "Running s390 jmeter test"
	./jmeter.sh -i ghcr.io/cage1016/jmeter-s390x:5.4.1 -d podman -f ap.jmx -t xx -l OUTPUT_FOLDER=$(PWD)/xx,TARGET_HOST=localhost,TARGET_PORT=8080,THREADS=10,RAMD_UP=10,DURATION=20

.PHONY: build-x86
build-x86: ## build-x86 jmeter container image
	@echo "Building x86 jmeter container image"

	docker build \
	--build-arg JMETER_VERSION=5.4.1 \
	--build-arg JMETER_PLUGINS_MANAGER_VERSION=1.3 \
	--build-arg CMDRUNNER_VERSION=2.2 \
	-t "ghcr.io/cage1016/jmeter:5.4.1" \
	-f Dockerfile .

.PHONY: build-s390x
build-s390x: ## build-s390x jmeter container image
	@echo "Building s390x jmeter container image"

	JMETER_VERSION=5.4.1 \
	JMETER_PLUGINS_MANAGER_VERSION=1.3 \
	CMDRUNNER_VERSION=2.2 \
	podman build \
	--build-arg JMETER_VERSION=5.4.1 \
	--build-arg JMETER_PLUGINS_MANAGER_VERSION=1.3 \
	--build-arg CMDRUNNER_VERSION=2.2 \
	-t "ghcr.io/cage1016/jmeter-s390x:5.4.1" \
	-f Dockerfile.s390x .

.PHONY: help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_0-9-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.DEFAULT_GOAL := help