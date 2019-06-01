IMAGE_TAG=gcr.io/knplabs-219508/taiga:$(TAG)

.PHONY: build
build: .check-image-tag
	docker build -t $(IMAGE_TAG) .

.PHONY: push
push: .check-image-tag
	docker push $(IMAGE_TAG)

.PHONY: .check-image-tag
.check-image-tag:
ifeq ($(TAG),)
	$(error You have to provide a TAG env var.)
endif
