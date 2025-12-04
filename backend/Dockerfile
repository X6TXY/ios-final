FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nano \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy source into /app/src so that Python can import the top-level package "src"
COPY ./src /app/src
COPY .env /app/.env

ENV PYTHONPATH=/app

EXPOSE 8000

RUN adduser --disabled-password --gecos '' appuser
USER appuser

# default command (docker-compose can override)
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]