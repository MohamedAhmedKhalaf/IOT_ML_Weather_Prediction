import paho.mqtt.client as mqtt
import sqlite3
import json
import time
from datetime import datetime
import pandas as pd
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
 
from http.server import HTTPServer, SimpleHTTPRequestHandler
from threading import Thread
 

MQTT_BROKER = "192.168.1.15"  
MQTT_PORT = 1883
MQTT_TOPIC = "nodered/sensor/data"
MQTT_TOPIC_REGRESSION = "python/regression/data"
HTTP_HOST = "0.0.0.0"
HTTP_PORT = 8001
 

db_name = "sensor_data.db"
 

sensor_data_buffer = []
 

def init_db():
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()
 
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS sensor_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            temperature REAL,
            humidity REAL,
            rain INTEGER,
            windspeed INTEGER,
            light INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
 
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS daydata (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            temperature REAL,
            humidity REAL,
            rain INTEGER,
            windspeed INTEGER,
            light INTEGER
        )
    ''')
 
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS nightdata (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            temperature REAL,
            humidity REAL,
            rain INTEGER,
            windspeed INTEGER,
            light INTEGER
        )
    ''')
 
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS dayavg (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date DATE,
            temperature_avg REAL,
            humidity_avg REAL,
            rain_avg REAL,
            windspeed_avg REAL,
            light_avg REAL
        )
    ''')
 
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS nightavg (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date DATE,
            temperature_avg REAL,
            humidity_avg REAL,
            rain_avg REAL,
            windspeed_avg REAL,
            light_avg REAL
        )
    ''')
 
    conn.commit()
    conn.close()
 

def insert_sensor_data(temperature, humidity, rain, windspeed, light):
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()
    current_time = datetime.now()
 

    cursor.execute('''
        INSERT INTO sensor_data (temperature, humidity, rain, windspeed, light, timestamp)
        VALUES (?, ?, ?, ?, ?, ?)
    ''', (temperature, humidity, rain, windspeed, light, current_time.strftime('%Y-%m-%d %H:%M:%S')))
 
 
    day_start = current_time.replace(hour=6, minute=0, second=0, microsecond=0)
    day_end = current_time.replace(hour=18, minute=0, second=0, microsecond=0)
 

    if day_start <= current_time < day_end:
        cursor.execute('''
            INSERT INTO daydata (temperature, humidity, rain, windspeed, light)
            VALUES (?, ?, ?, ?, ?)
        ''', (temperature, humidity, rain, windspeed, light))
    else:
        cursor.execute('''
            INSERT INTO nightdata (temperature, humidity, rain, windspeed, light)
            VALUES (?, ?, ?, ?, ?)
        ''', (temperature, humidity, rain, windspeed, light))
 
    conn.commit()
    conn.close()
 
def calculate_buffer_avg():
    if len(sensor_data_buffer) == 0:
        return None
    temperature_avg = sum([data[0] for data in sensor_data_buffer]) / len(sensor_data_buffer)
    humidity_avg = sum([data[1] for data in sensor_data_buffer]) / len(sensor_data_buffer)
    rain_avg = sum([data[2] for data in sensor_data_buffer]) / len(sensor_data_buffer)
    windspeed_avg = sum([data[3] for data in sensor_data_buffer]) / len(sensor_data_buffer)
    light_avg = sum([data[4] for data in sensor_data_buffer]) / len(sensor_data_buffer)
    return (temperature_avg, humidity_avg, rain_avg, windspeed_avg, light_avg)
 
last_received_message = None
 
def on_message(client, userdata, message):
    global last_received_message
    payload = str(message.payload.decode("utf-8"))
    try:
        data = json.loads(payload)
        if data != last_received_message:
            temperature = data.get("temperature")
            humidity = data.get("humidity")
            rain = data.get("rain")
            windspeed = data.get("windspeed")
            light = data.get("light")
            sensor_data_buffer.append((temperature, humidity, rain, windspeed, light))
            print(f"Data received: {data}")
            last_received_message = data
    except json.JSONDecodeError:
        print("Error: Failed to decode JSON message")
 
def load_data():
    conn = sqlite3.connect(db_name)
    query = "SELECT temperature, humidity, windspeed, light, rain FROM sensor_data"
    df = pd.read_sql(query, conn)
    conn.close()
    print(f"Data loaded from database: {df.shape[0]} rows")
    return df
 
def load_data2():
    conn = sqlite3.connect(db_name)
    query = "SELECT temperature_avg, humidity_avg, windspeed_avg, light_avg, rain_avg FROM dayavg"
    df = pd.read_sql(query, conn)
    conn.close()
    print(f"Data loaded from database: {df.shape[0]} rows")
    return df
 
def load_data3():
    conn = sqlite3.connect(db_name)
    query = "SELECT temperature_avg, humidity_avg, windspeed_avg, light_avg, rain_avg FROM nightavg"
    df = pd.read_sql(query, conn)
    conn.close()
    print(f"Data loaded from database: {df.shape[0]} rows")
    return df

def perform_logistic_regression():
    df = load_data()
    if len(df) < 10:  
        print("Not enough data to perform logistic regression.")
        return None, None, None, None
 
    X = df[['temperature', 'humidity', 'windspeed', 'light']]
    y = df['rain'] == 1
 
    if y.nunique() < 2:
        print("Data contains only one class. Logistic regression requires at least two classes.")
        return None, None, None, None
 
    model = LogisticRegression()
    model.fit(X, y)
 
    latest_data = df.iloc[[-1]][['temperature', 'humidity', 'windspeed', 'light']]
    print(f"Latest data for prediction: {latest_data}")
 
    rain_prob = model.predict_proba(latest_data)[0][1]
    rain_prediction = int(rain_prob > 0.5)
 
    coefficients = model.coef_[0].tolist()
    intercept = model.intercept_[0]
 
    print(f"Logistic Regression Coefficients: {coefficients}")
    print(f"Intercept: {intercept}")
    return rain_prob, rain_prediction, coefficients, intercept
 

def linear_regression(dayNight:bool):
    if (dayNight == True):
        df2 = load_data2()
    else:
        df2 = load_data3()
 
 
    df2 = df2.tail(30)
    if len(df2) < 10:
        print("Not enough data to perform linear regression.")
        return None, None, None, None
 
 
    X = df2.index.values.reshape(-1, 1)
    y = df2['temperature_avg'].values
 
 
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
 
 
    model = LinearRegression()
    model.fit(X_train, y_train)
 
 
    coef_ = model.coef_
    y_pred = model.predict(X_test)
 
 
    r2_ = r2_score(y_test, y_pred)
 
    print(f"Model coefficients: {coef_}")
    print(f"R-squared score: {r2_}")
 
    return model
 
 
def linear_regressionHum(dayNight:bool):
    if (dayNight == True):
        df2 = load_data2()
    else:
        df2 = load_data3()
 
 
    df2 = df2.tail(30)
    if len(df2) < 10:
        print("Not enough data to perform linear regression.")
        return None, None, None, None
 
 
    X = df2.index.values.reshape(-1, 1)
    y = df2['humidity_avg'].values
 
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
 
 
    model = LinearRegression()
    model.fit(X_train, y_train)
 
 
    coef_ = model.coef_
    y_pred = model.predict(X_test)
 
 
    r2_ = r2_score(y_test, y_pred)
 
    print(f"Model coefficients: {coef_}")
    print(f"R-squared score: {r2_}")
 
    return model
 
def perform_regression_data():
    rain_result = perform_logistic_regression()
    temp_model_day = linear_regression(dayNight=True)
    hum_model_day = linear_regressionHum(dayNight=True)
    temp_model_night = linear_regression(dayNight=False)
    hum_model_night = linear_regressionHum(dayNight=False)
 
    if rain_result[0] is not None and temp_model_day is not None and hum_model_day is not None:
        rain_prob, rain_prediction, coefficients, intercept = rain_result
        regression_data = {
            "rain_probability": rain_prob,
            "rain_prediction": rain_prediction,
            "temperature_prediction_day": {
                "day+1": temp_model_day.predict([[31]]).tolist(),
                "day+2": temp_model_day.predict([[32]]).tolist(),
                "day+3": temp_model_day.predict([[33]]).tolist()
            },
            "humidity_prediction_day": {
                "day+1": hum_model_day.predict([[31]]).tolist(),
                "day+2": hum_model_day.predict([[32]]).tolist(),
                "day+3": hum_model_day.predict([[33]]).tolist()
            },
            "temperature_prediction_night": {
                "night+1": temp_model_night.predict([[31]]).tolist(),
                "night+2": temp_model_night.predict([[32]]).tolist(),
                "night+3": temp_model_night.predict([[33]]).tolist()
            },
            "humidity_prediction_night": {
                "night+1": hum_model_night.predict([[31]]).tolist(),
                "night+2": hum_model_night.predict([[32]]).tolist(),
                "night+3": hum_model_night.predict([[33]]).tolist()
            }
        }
        return regression_data
    else:
        return {"error": "Regression data is not available."}
 
 
def calculate_and_store_daily_averages():
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()
 
 
    cursor.execute('''
        SELECT AVG(temperature) as temperature_avg,
               AVG(humidity) as humidity_avg,
               AVG(rain) as rain_avg,
               AVG(windspeed) as windspeed_avg,
               AVG(light) as light_avg
        FROM daydata
    ''')
    day_avg = cursor.fetchone()
    if day_avg:
        cursor.execute('''
            INSERT INTO dayavg (date, temperature_avg, humidity_avg, rain_avg, windspeed_avg, light_avg)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (datetime.now().strftime('%Y-%m-%d'), *day_avg))
 
 
    cursor.execute('''
        SELECT AVG(temperature) as temperature_avg,
               AVG(humidity) as humidity_avg,
               AVG(rain) as rain_avg,
               AVG(windspeed) as windspeed_avg,
               AVG(light) as light_avg
        FROM nightdata
    ''')
    night_avg = cursor.fetchone()
    if night_avg:
        cursor.execute('''
            INSERT INTO nightavg (date, temperature_avg, humidity_avg, rain_avg, windspeed_avg, light_avg)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (datetime.now().strftime('%Y-%m-%d'), *night_avg))
 
 
    cursor.execute('DELETE FROM daydata')
    cursor.execute('DELETE FROM nightdata')
 
    conn.commit()
    conn.close()
 
 
def setup_mqtt():
    client = mqtt.Client()
    client.on_message = on_message
    try:
        client.connect(MQTT_BROKER, MQTT_PORT)
        client.subscribe(MQTT_TOPIC)
    except Exception as e:
        print(f"Error: Could not connect to MQTT broker. {e}")
    return client
 
class RegressionDataHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/regression_data':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            regression_data = perform_regression_data()
            self.wfile.write(json.dumps(regression_data).encode())
        else:
            self.send_error(404)
 
 
def start_http_server():
    server_address = (HTTP_HOST, HTTP_PORT)
    httpd = HTTPServer(server_address, RegressionDataHandler)
    print(f"Starting HTTP server on {HTTP_HOST}:{HTTP_PORT}")
    httpd.serve_forever()
 
 
if __name__ == "__main__":
    init_db()
    client = setup_mqtt()
    client.loop_start()
 
 
    http_thread = Thread(target=start_http_server)
    http_thread.start()
 
    try:
        while True:
            now = datetime.now()
 
            if now.hour == 0 and now.minute == 0:
                calculate_and_store_daily_averages()
 
            time.sleep(60)
 
            avg_data = calculate_buffer_avg()
            if avg_data:
                insert_sensor_data(*avg_data)
                print(f"Average data inserted: {avg_data}")
 
            sensor_data_buffer.clear()
 
    except KeyboardInterrupt:
        print("Script interrupted by user.")
    finally:
        client.loop_stop()
        client.disconnect()