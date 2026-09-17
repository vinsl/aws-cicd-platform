FROM python:3.11-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN apt-get update && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/*

RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser

COPY requirements.txt .

RUN python -m pip install --no-cache-dir --upgrade \
        "pip>=26.0" \
        "setuptools>=78.1.1" \
        "wheel>=0.46.2" && \
    python -m pip install --no-cache-dir -r requirements.txt && \
    python -m pip uninstall -y pip setuptools wheel && \
    rm -rf \
        /usr/local/lib/python3.11/site-packages/pip* \
        /usr/local/lib/python3.11/site-packages/setuptools* \
        /usr/local/lib/python3.11/site-packages/wheel* \
        /usr/local/bin/pip* \
        /usr/local/bin/wheel*

COPY app.py .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--threads", "2", "--timeout", "30", "app:app"]