---
author: "Evandro Pavei"
date: 2020-08-20
linktitle: Deploy Hugo Blog with Docker and Dokku
title: Deploy Hugo Blog with Docker and Dokku
weight: 10
tags : [
    "docker",
    "dokku",
    "heroku"
]
draft: true
---


## 

For the docker image I am using the image I am using [this](https://hub.docker.com/r/klakegg/hugo/)

Create a Dockerfile in the root folder of the project with the following content:
```Dockerfile
    # ---- Hugo ---
    FROM klakegg/hugo:0.74.3-onbuild AS hugo

    # ---- Nginx ----
    FROM nginx:1.18 as nginx
    COPY --from=hugo /target /usr/share/nginx/html
```

```bash
    git push dokku master
```
That's it. Dokku will recognize the Dockerfile in the root folder of the project with build the file in the first step and copy it to the Nginx image to run it.


To test it locally, build the docker image and run it:

Build the image:
```bash
	docker build \
        --tag hugo-blog_nginx \
		--build-arg HUGO_ENV_ARG="production" \
		--build-arg HUGO_DESTINATION_ARG="/target" \
		--target=nginx \
		--file=./Dockerfile .
```

Run the nginx image:
```bash
	docker run --rm \
		--name hugo-blog_nginx \
		-e NGINX_ENTRYPOINT_QUIET_LOGS=1 \
		-p 1313:80 \
		hugo-blog_nginx
```

Blog will be running on [http://localhost:1313](http://localhost:1313)



