FROM python:3.10-slim
WORKDIR /app
ENV PIP_NO_CACHE_DIR=1
COPY . .
RUN python -m pip install --upgrade pip && \
    pip install flask scikit-learn pandas numpy
EXPOSE 5000
CMD ["python", "anomaly_detector.py"]
