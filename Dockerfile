# # ---- Hugo ---
# FROM klakegg/hugo:0.74.3-onbuild AS hugo

# # ---- Nginx ----
# FROM nginx:1.18 as nginx
# COPY --from=hugo /target /usr/share/nginx/html

# -----------------------------------------------------
# With build env var

# ---- Hugo ----
FROM klakegg/hugo:0.74.3 as hugo
COPY . /src
ARG GOOGLE_ANALYTICS_TAG
ENV HUGO_GoogleAnalytics=${GOOGLE_ANALYTICS_TAG}
RUN hugo

# ---- Nginx ----
FROM nginx:1.18 as nginx
COPY --from=hugo /src/public/ /usr/share/nginx/html