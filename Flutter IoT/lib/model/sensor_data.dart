import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SensorData {
  final String MQTT_BROKER = "192.168.1.15";
  final int MQTT_PORT = 1883;
  final String MQTT_TOPIC = "nodered/sensor/data";
  final String HTTP_SERVER = "http://192.168.1.15:8001";

  late MqttServerClient client;

  Function(Map<String, dynamic>)? onSensorDataReceived;

  SensorData() {
    setupMqttClient();
  }

  Future<void> setupMqttClient() async {
    client = MqttServerClient(MQTT_BROKER, 'flutter_client');
    client.port = MQTT_PORT;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
  }

  Future<void> connectToMqttBroker() async {
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      client.subscribe(MQTT_TOPIC, MqttQos.atMostOnce);
    } else {
      print(
          'MQTT client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      final sensorData = json.decode(payload);
      onSensorDataReceived?.call(sensorData);
    });
  }

  void onConnected() {
    print('Connected to MQTT broker');
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  Future<Map<String, dynamic>> fetchRegressionData() async {
    try {
      final response =
          await http.get(Uri.parse('$HTTP_SERVER/regression_data'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load regression data');
      }
    } catch (e) {
      print('Error fetching regression data: $e');
      return {};
    }
  }

  void dispose() {
    client.disconnect();
  }
}
