VERSION ?= 0.0.1
IMG ?= kube-host-vm:v$(VERSION)

.PHONY: build-amd64
build-amd64: build-amd64
	docker buildx build --network host --load --platform linux/amd64 -t ${IMG} .

.PHONY: build-arm64
build-arm64: build-arm64
	docker buildx build --network host --load --platform linux/arm64 -t ${IMG} .
