# Use official Python image
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock* README.md /app/

# Build argument to determine if dev dependencies should be installed
ARG INSTALL_DEV=true

# Install dependencies
RUN if [ "$INSTALL_DEV" = "true" ]; then \
    uv sync --frozen; \
    else \
    uv sync --frozen --no-dev; \
    fi

# Copy application code
COPY . /app/

EXPOSE 8501

# Use uv run to execute streamlit
CMD ["uv", "run", "streamlit", "run", "src/main.py", "--server.port=8501", "--server.address=0.0.0.0"]
