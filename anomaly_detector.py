import pandas as pd
from sklearn.ensemble import IsolationForest
import numpy as np
import time, random

model = IsolationForest(contamination=0.05)
history = []

while True:
    latency = random.gauss(100, 15)
    history.append(latency)
    if len(history) > 50:
        data = np.array(history).reshape(-1, 1)
        model.fit(data)
        pred = model.predict([[latency]])
        if pred[0] == -1:
            print(f"[ALERTA IA] Latencia anómala detectada: {latency} ms")
    time.sleep(2)
