# Use the official Python runtime as a parent image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /docs

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    mkdocs-material \
    mkdocs-git-revision-date-localized-plugin \
    mkdocs-git-committers-plugin-2 \
    mkdocs-minify-plugin \
    mkdocs-redirects \
    mkdocs-glightbox

# Copy MkDocs documentation source files and configuration
COPY manifests/mkdocs-docs/ .

# Expose port
EXPOSE 8000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Set entrypoint and command to serve MkDocs documentation
ENTRYPOINT ["mkdocs"]
CMD ["serve", "--dev-addr=0.0.0.0:8000"]
