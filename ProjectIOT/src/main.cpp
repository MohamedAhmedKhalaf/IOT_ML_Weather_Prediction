#include <Wire.h>
#include <PubSubClient.h>
#include <Arduino.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <WiFi.h>
#include <DHT.h>
#include <DHT_U.h>
#include <Adafruit_BMP280.h>

// Define screen width and height for OLED display
#define SCREEN_WIDTH 128 
#define SCREEN_HEIGHT 64 

// Initialize OLED display object
Adafruit_SSD1306 oled(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// Define sensor pins
const int MQpin = 39;
const int DHTpin = 33;
const int IRpin = 32;
const int Rainpin = 35;
const int Lightpin = 34;

// Initialize DHT22 temperature and humidity sensor
DHT_Unified dht(DHTpin, DHT22);

// Initialize BMP280 barometric pressure sensor
Adafruit_BMP280 bmp;

// Initialize WiFi and MQTT server topics
const char *ssid = "MOELMAGHRABI";
const char *password = "ow3wJacP";
const char *mqttServer = "192.168.1.15";
const char *tempTopic = "esp32/sensor/temp";
const char *humdTopic = "esp32/sensor/humd";
const char *rainTopic = "esp32/sensor/rain";
const char *aqTopic = "esp32/sensor/airquality";
const char *wsTopic = "esp32/sensor/windspeed";
const char *lightTopic = "esp32/sensor/light";
const char *pressureTopic = "esp32/sensor/pressure";

const int mqttPort = 1883; // MQTT port number

// Create WiFi and MQTT clients
WiFiClient espClient;
PubSubClient client(espClient);

float vane_diameter = 130; // Diameter of the wind vane in mm
float vane_circ = (vane_diameter / 1000.0) * 3.1415; // Circumference of wind vane in meters
float afactor = 1.3; // Wind speed correction factor

// Function to initialize the OLED display and display a loading screen
void initializing()
{
    oled.clearDisplay();
    oled.setTextSize(2);
    oled.setCursor(47, 0);
    oled.setTextColor(SSD1306_WHITE);
    oled.println(F("IoT"));

    oled.fillRect(15, 20, 93, 28, SSD1306_WHITE); // Draw a rectangle on the screen

    oled.setTextSize(1);
    oled.setTextColor(SSD1306_BLACK);
    oled.setCursor(17, 25);
    oled.println(F("Loading Sensors"));
    oled.setCursor(49, 36);
    oled.println(F("Data!"));

    oled.setTextSize(1);
    oled.setCursor(18, 52);
    oled.setTextColor(SSD1306_WHITE);
    oled.println(F("Field Training!"));

    oled.display();

    delay(5000);
}
#define WIRE Wire

// Function to connect to Wi-Fi
void setup_wifi()
{
    delay(10);
    Serial.print("Connecting to ");
    Serial.println(ssid);
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(1000);
        Serial.print(".");
    }
    Serial.println("WiFi connected");
}

// Function to draw sensor data on the OLED display
void drawDataScreen(float temperature, float humidity, float pressure, int airQuality, float windSpeed)
{
    oled.clearDisplay(); 

    oled.setTextSize(2); 
    oled.setTextColor(SSD1306_WHITE);

    oled.setCursor(2, 0);
    oled.println(F("Sens Data"));

    oled.setTextSize(1); 
    oled.setCursor(0, 19);
    oled.print(F("Temp: "));
    oled.print(temperature);
    oled.println(F(" C"));

    oled.setCursor(0, 28);
    oled.print(F("Humidity: "));
    oled.print(humidity);
    oled.println(F(" %"));

    oled.setCursor(0, 38);
    oled.print(F("Pressure: "));
    oled.print(pressure);
    oled.println(F(" hPa"));

    oled.setCursor(0, 48);
    oled.print(F("Air Quality: "));
    oled.print(airQuality);
    oled.println("ppm");

    oled.setCursor(0, 57);
    oled.print(F("Wind Speed: "));
    oled.print(windSpeed);
    oled.println("kph");

    oled.display();
}

// Function to connect to the MQTT broker
void mqtt_connect()
{
    while (!client.connected())
    {
        Serial.print("Connecting to MQTT...");

        if (client.connect("ESP32Client"))
        {
            Serial.println("connected");
        }
        else
        {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            delay(5000);
        }
    }
}

// MQTT callback function for handling messages
void callback(char *topic, byte *message, unsigned int length)
{
    String messageTemp;
    String lcdmsg;

    for (int i = 0; i < length; i++)
    {
        messageTemp += (char)message[i];
    }
}

// Main function
void setup()
{
    Serial.begin(115200);
    if (!oled.begin(SSD1306_SWITCHCAPVCC, 0x3C)) // Initialize the OLED Screen
    {
        Serial.println(F("failed to start SSD1306 OLED"));
        while (1)
            ;
    }
    initializing(); // Display the Loading screen

    if (!bmp.begin(0x76)) // Initialize BMP280 sensor
    {
        Serial.println(F("Could not find a valid BMP280 sensor, check wiring!"));
        while (1)
            ;
    }

    setup_wifi(); // Connect to Wi-Fi
    client.setServer(mqttServer, mqttPort); // Set MQTT server
    client.setCallback(callback); // Set MQTT callback function
    dht.begin(); // Initialize DHT sensor
    // Set pin modes for sensors
    pinMode(IRpin, INPUT);
    pinMode(Rainpin, INPUT);
    pinMode(MQpin, INPUT);
    pinMode(Lightpin, INPUT);
}

// Main Loop Function
void loop()
{
    if (!client.connected())
    {
        mqtt_connect(); // Ensure connection to the MQTT broker
    }
    client.loop();

    // Initializing sensors variables
    float temp;
    float humd;
    float pressure;
    int airQuality;
    float windSpeed;

    sensors_event_t event;
    dht.temperature().getEvent(&event);
    if (isnan(event.temperature))
    {
        Serial.println(F("Error reading temperature!")); // Check if temperature reading is valid
    }
    else
    {
        Serial.print("Temp: ");
        Serial.println(event.temperature); // Output temperature to Serial monitor
        temp = event.temperature;
        client.publish(tempTopic, String(event.temperature).c_str()); // Publish temperature to MQTT
    }

    delay(100);
    dht.humidity().getEvent(&event);
    if (isnan(event.relative_humidity))
    {
        Serial.println(F("Error reading humidity!")); // Check if humidity 
    }
    else
    {
        Serial.print("Humd: ");
        Serial.println(event.relative_humidity); // Output humidity to Serial monitor
        humd = event.relative_humidity;
        client.publish(humdTopic, String(event.temperature).c_str()); // Publish humidity to MQTT
    }

    pressure = bmp.readPressure() / 100.0F; // Read pressure in hPa
    client.publish(pressureTopic, String(pressure).c_str()); // Publish pressure to MQTT
    Serial.print("Pressure: ");
    Serial.println(pressure); // Output pressure to Serial monitor

    airQuality = analogRead(MQpin); // Read air quality from MQ sensor
    client.publish(aqTopic, String(airQuality).c_str()); // Publish air quality to MQTT
    Serial.print("Air Quality: ");
    Serial.println(airQuality); // Output air quality to Serial monitor

    // Wind speed calculation using the IR sensor
    float rotations = 0;
    bool trigger = false;
    float endtime = millis() + 10000; // Set time window for measuring wind speed
    int sensorstart = digitalRead(IRpin); // Read initial state of the IR sensor

    // Loop for 10 seconds to measure rotations
    while (millis() < endtime)
    {
        if (digitalRead(IRpin) == HIGH && !trigger)
        {
            rotations++;
            trigger = true;
        }
        else if (digitalRead(IRpin) == LOW)
        {
            trigger = false;
        }
        delay(1); 
    }
    if (rotations == 1 && sensorstart == HIGH)
    {
        rotations = 0; // Ignore first rotation if sensor starts high
    }

    // Calculate wind speed in kph
    float rots_per_second = rotations / 10.0; // Rotations per second
    float windSpeed1 = (rots_per_second * vane_circ * afactor) * 3.6; // Wind speed in kph
    Serial.print("Wind Speed: ");
    Serial.println(windSpeed1); // Output wind speed to Serial monitor
    Serial.print("RPM");
    Serial.println(rots_per_second * 60); // Output rotations per minute

    client.publish(rainTopic, String(digitalRead(Rainpin)).c_str()); // Publish rainfall to MQTT
    client.publish(wsTopic, String(windSpeed1).c_str()); // Publish wind speed to MQTT
    client.publish(lightTopic, String(analogRead(Lightpin)).c_str()); // Publish light sensor data to MQTT

    // Display sensor data on the OLED screen
    drawDataScreen(temp, humd, pressure, airQuality, windSpeed1);
}