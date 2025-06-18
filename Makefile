VERSION ?= 0.0.4
IMG ?= kube-host-vm:v$(VERSION)

.PHONY: build-amd64
build-amd64: build-amd64
	docker buildx build --network host --load --platform linux/amd64 -t ${IMG} .

.PHONY: build-arm64
build-arm64: build-arm64
	docker buildx build --network host --load --platform linux/arm64 -t ${IMG} .

CUST_LIBVIRT_IMG ?= kube-host-vm:v$(VERSION)

.PHONY: build-libvirt-amd64
build-libvirt-amd64: build-libvirt-amd64
	docker buildx build --network host --load --platform linux/amd64 -t ${CUST_LIBVIRT_IMG} -f Dockerfile-custom-libvirt .

.PHONY: build-libvirt-arm64
build-libvirt-arm64: build-libvirt-arm64
	docker buildx build --network host --load --platform linux/arm64 -t ${CUST_LIBVIRT_IMG} -f Dockerfile-custom-libvirt .
