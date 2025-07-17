FROM squidfunk/mkdocs-material:latest as builder

# Copy the documentation source
WORKDIR /docs
COPY docs/ ./docs/
COPY mkdocs.yml ./

# Build the static site
RUN mkdocs build

# Production stage with nginx
FROM nginx:alpine

# Copy the built site from builder stage
COPY --from=builder /docs/site /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Use non-root user
USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
