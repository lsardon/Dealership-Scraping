FROM python:3.11-slim

# Install system dependencies for web scraping
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-driver \
    firefox-esr \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install additional scraping libraries if not in requirements
RUN pip install --no-cache-dir \
    selenium \
    beautifulsoup4 \
    pandas \
    requests \
    lxml

# Copy application code
COPY . .

# Create output directory for scraped data
RUN mkdir -p /app/output

# Set environment variables for headless browsing
ENV PYTHONUNBUFFERED=1
ENV DISPLAY=:99

# Default command (adjust based on main script)
CMD ["python", "main.py"]
