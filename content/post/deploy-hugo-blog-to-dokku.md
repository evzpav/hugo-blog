---
author: "Evandro Pavei"
date: 2020-08-28
title: Simplest way to Deploy a Hugo Blog (HUGO + DOKKU)
weight: 10
tags : [
    "docker",
    "dokku",
    "hugo"
]
---


## How to deploy a Hugo blog with Dokku (Docker) in your virtual machine.
This blog is made with [Hugo](https://gohugo.io/), which is a famous framework made with Golang to build static websites. And as I am used to deploying my projects using [Dokku](http://dokku.viewdocs.io/dokku/), I figured a good way to deploy it (this blog is deployed with Dokku).

In order to deploy to Dokku, my personal preference it to [deploy Dokku using Dockerfiles](http://dokku.viewdocs.io/dokku/deployment/methods/dockerfiles/
), because I have more control to specify the images version and set variables etc and it is a more standardized way to deploy for every programming language. It just works fine.

In the Hugo project, create a `Dockerfile` in the root folder of the project with the following content:

```Dockerfile
    # ---- Hugo ---
    FROM klakegg/hugo:0.74.3-onbuild AS hugo

    # ---- Nginx ----
    FROM nginx:1.18 as nginx
    COPY --from=hugo /target /usr/share/nginx/html
```

**That's it, done**. Then commit and push to dokku remote:
```bash
    git add .
    git commit -m "Add Dockerfile"
    git push dokku master
```
 Dokku will recognize the Dockerfile in the root folder of the project, it will generate the build files in the first docker step and it will copy it to the Nginx image to serve the static pages.

### Testing in your machine first:

Build the image (`hugo-blog_nginx`):
```bash
	DOCKER_BUILDKIT=1 \
	docker build  \
	 --progress=plain \
		--tag hugo-blog_nginx \
		--target=nginx \
		--file=./Dockerfile .
```

Run the Nginx image:
```bash
	docker run --rm \
		--name hugo-blog \
		-e NGINX_ENTRYPOINT_QUIET_LOGS=1 \
		-p 1313:80 \
		hugo-blog_nginx
```

Blog will be running on [http://localhost:1313](http://localhost:1313)


## BONUS: How to pass environment variables to build static files in Hugo?

Normally, in my projects I set environment variables during runtime. But in case of Hugo, as it builds the static files, at runtime what you have is a bunch of html, js and css files and your env var is useless. So **the environment variable needs to be set at building time**. 
I had the idea to set the *Google Analytics tag*, but did not want to commit it to the project. So I preferred to pass it as environment variable to avoid to hardcode it.

In the `config.toml` file there is this variable called `GoogleAnalytics=""`.
Hugo accepts env vars with prefix of `HUGO_`. So the env var is called:  `HUGO_GoogleAnalytics`.

Dockerfile is a bit different than before:
```Dockerfile
 # ---- Hugo ----
FROM klakegg/hugo:0.74.3 as hugo
COPY . /src
ARG GOOGLE_ANALYTICS_TAG # build argument
ENV HUGO_GoogleAnalytics=${GOOGLE_ANALYTICS_TAG} # then set to hugo format
RUN hugo

# ---- Nginx ----
FROM nginx:1.18 as nginx
COPY --from=hugo /src/public/ /usr/share/nginx/html
```

It takes the ARG `GOOGLE_ANALYTICS_TAG`, that will be passed during `docker build` command.
And that is set as env var for `hugo` command. So when hugo creates the static files it will automatically know the Google Analytics Tag and will add it to the html, according to definitions in the template.

### Testing locally:

Build the image:
```bash
	DOCKER_BUILDKIT=1 \
	docker build  \
	 --progress=plain \
		--tag hugo-blog_nginx \
		--build-arg GOOGLE_ANALYTICS_TAG=mytag \
		--target=nginx \
		--file=./Dockerfile .
```

Run locally to test (same as before):
```bash
	docker run --rm \
		--name hugo-blog \
		-e NGINX_ENTRYPOINT_QUIET_LOGS=1 \
		-p 1313:80 \
		hugo-blog_nginx
```
Blog will be running on [http://localhost:1313](http://localhost:1313).  
Inspect in the browser tools the html in the elements tab to see if the Google Analytics Tag is there or not.


Now, for Dokku to understand what to do during build you have to set the env var **NOT** with `dokku config` command, because those variables are for runtime.
**The variable needs to be set for `build` stage**.
According to docs ([Dokku build time config vars](http://dokku.viewdocs.io/dokku/deployment/methods/dockerfiles/#build-time-configuration-variables)) you need to use the `docker-options` plugin like below. So run it in your VM:

```bash
dokku docker-options:add hugo-blog \
    build '--build-arg GOOGLE_ANALYTICS_TAG=mygoogleanalyticstagcode'
```

### Extra: Makefile:

For convenience, I run the command in my machine with `make`. Have it installed: [Make](https://www.gnu.org/software/make/)  
I create a `Makefile` in the root folder of the project:

```Makefile
include .env

NAME = $(shell basename $(CURDIR))
PORT = 1313

build-local:
	hugo

run-local:
	hugo server -D

build-docker:
	DOCKER_BUILDKIT=1 \
	docker build  \
		--progress=plain \
		--tag $(NAME)_nginx \
		--build-arg GOOGLE_ANALYTICS_TAG=$(GOOGLE_ANALYTICS_TAG) \
		--build-arg HUGO_ENV_ARG="production" \
		--build-arg HUGO_DESTINATION_ARG="/target" \
		--target=nginx \
		--file=./Dockerfile .

run-docker: build-docker
	docker run --rm \
		--name $(NAME)_nginx \
		-e NGINX_ENTRYPOINT_QUIET_LOGS=1 \
		-p $(PORT):80 \
		$(NAME)_nginx
	$(info running on http://localhost:$(PORT))

```

Add a `.env` file (add it to .gitignore file as well so it is not commited to project):
```.env
GOOGLE_ANALYTICS_TAG=mygoogleanalyticstag
``` 

Then I just run:
```bash
make run-local
```
To run the hugo development server while writing a post.

And to see how it would be as deployed:
```bash
make run-docker
```

Link to Github repository: (https://github.com/evzpav/hugo-blog)

Thanks for reading!
For questions or comments follow me on [Twitter](https://twitter.com/evzpav) and send me a direct message ;).