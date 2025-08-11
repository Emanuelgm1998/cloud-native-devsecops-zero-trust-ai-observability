FROM python:3.10

WORKDIR /app
COPY . .

RUN pip install flask scikit-learn pandas

CMD ["python", "anomaly_detector.py"]
