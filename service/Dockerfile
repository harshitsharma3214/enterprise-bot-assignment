
# Build stage
FROM python:3.12.8-slim-bookworm AS builder

WORKDIR /build

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Runtime stage
FROM python:3.12.8-slim-bookworm

WORKDIR /app

COPY --from=builder /install /usr/local

COPY app.py .

RUN useradd --system --uid 10001 appuser

USER 10001

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
