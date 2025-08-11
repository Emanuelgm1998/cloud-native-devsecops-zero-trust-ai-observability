FROM python:3.10
WORKDIR /app
COPY . .
RUN pip install flask scikit-learn pandas
EXPOSE 5000
CMD ["python", "anomaly_detector.py"]
