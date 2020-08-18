include .env

NAME = $(shell basename $(CURDIR))
PORT = 8080

build-local:
	HUGO_GoogleAnalytics=$(GOOGLE_ANALYTICS_TAG) \
	hugo

run-local:
	HUGO_GoogleAnalytics=$(GOOGLE_ANALYTICS_TAG) \
	hugo server -D

build-nginx:
	DOCKER_BUILDKIT=1 \
	docker build  \
	 --progress=plain \
		--tag $(NAME)_nginx \
		--build-arg HUGO_ENV_ARG="production" \
		--build-arg HUGO_DESTINATION_ARG="/target" \
		--target=nginx \
		--file=./Dockerfile .

run-nginx: build-nginx
	docker run --rm \
		--name $(NAME)_nginx \
		-e NGINX_ENTRYPOINT_QUIET_LOGS=1 \
		-p $(PORT):80 \
		$(NAME)_nginx
	$(info running on http://localhost:$(PORT))

build-docker:
	docker run --rm -it \
  		-v $$(pwd):/src \
		--tag $(NAME)_hugo \
		--target=hugo \
  		--file=./Dockerfile .

run-docker: build-docker
	docker run --rm -it \
		--name $(NAME)_hugo \
		-v $$(pwd):/src \
		-p 1313:1313 \
		$(NAME)_hugo \
		server
	$(info running on http://localhost:1313)


build-alpine:
	DOCKER_BUILDKIT=1 \
	docker build  \
	 	--progress=plain \
		--tag $(NAME)_alpine \
		--build-arg HUGO_ENV_ARG="production" \
		--build-arg HUGO_DESTINATION_ARG="/target" \
		--build-arg HUGO_CMD="" \
		--target=image \
		--file=./Dockerfile .

run-alpine: build-alpine
	docker run --rm \
		--name $(NAME)_alpine \
		-e PORT=$(PORT) \
		-p $(PORT):$(PORT) \
		$(NAME)_alpine
		
	$(info running on http://localhost:$(PORT))
