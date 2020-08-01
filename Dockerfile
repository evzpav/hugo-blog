# ---- Hugo ---
FROM klakegg/hugo:0.74.3-onbuild AS hugo

# ---- Nginx ----
FROM nginx:1.18 as nginx
COPY --from=hugo /target /usr/share/nginx/html

# ---- Go ---
FROM golang:1.14-stretch AS go
WORKDIR $GOPATH/src/github.com/evzpav/hugo-blog
COPY server.go .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -a -installsuffix cgo -o /bin/hugo-blog server.go

# ---- Image ----
FROM alpine AS image
COPY --from=hugo /target public/
COPY --from=go /bin/hugo-blog /hugo-blog
ENTRYPOINT ["/hugo-blog"]
