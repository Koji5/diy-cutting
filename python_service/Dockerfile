FROM python:3.12-slim

# フォントやcairo等は不要（PyMuPDFのみでPDF化可）
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv
COPY requirements.txt .
RUN pip install --no-cache-dir -U pip && pip install -r requirements.txt
RUN apt-get update -y && apt-get install -y --no-install-recommends \
      fonts-dejavu-core fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/*
COPY app ./app
EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
