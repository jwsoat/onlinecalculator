FROM nginx:alpine

# Copy static site
COPY . /usr/share/nginx/html

# Custom nginx config (clean URLs, gzip, asset caching)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Remove files that shouldn't be served
RUN rm -f /usr/share/nginx/html/Dockerfile \
         /usr/share/nginx/html/docker-compose.yml \
         /usr/share/nginx/html/nginx.conf \
         /usr/share/nginx/html/BUILD-GUIDE.md

EXPOSE 80
