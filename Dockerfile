# Multi-stage build for efficiency
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim

# Install runtime dependencies for web scraping
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/chromium /usr/bin/google-chrome

# Copy Python packages from builder
COPY --from=builder /root/.local /root/.local

WORKDIR /app

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/output /app/logs /app/data

# Make Python find the packages
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Chrome/Chromium settings for container
ENV CHROME_BIN=/usr/bin/chromium
ENV CHROME_PATH=/usr/lib/chromium/

# Run as non-root user (optional but recommended)
RUN useradd -m -u 1000 scraper && \
    chown -R scraper:scraper /app

USER scraper

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)" || exit 1

# Default command
CMD ["python", "-u", "main.py"]
