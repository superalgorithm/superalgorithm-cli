FROM python:3.13-slim AS base

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY base_images/default/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy common modules
COPY common/ /app/common/

# Set environment variables
ENV PYTHONPATH=/app
ENV CONFIG_FILE=/app/config.yaml
ENV MODE=live

# Default command
CMD ["python", "main.py"]