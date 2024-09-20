import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_iot/core/theme/theme.dart';
import 'package:project_iot/settings_screen/settings_screen.dart';
import 'package:project_iot/widgets/widget_of_data.dart';
import '../model/sensor_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  @override
  static const String routeName = "home_screen";

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SensorData _sensorDataService = SensorData();
  Map<String, dynamic> sensorData = {};
  Map<String, dynamic> regressionData = {};

  Future<void> _fetchRegressionData() async {
    final data = await _sensorDataService.fetchRegressionData();
    setState(() {
      regressionData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _sensorDataService.onSensorDataReceived = (data) {
      setState(() {
        sensorData = data;
      });
    };
    _sensorDataService.connectToMqttBroker();
    _fetchRegressionData();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    var appLocal = AppLocalizations.of(context)!;
    var theme = Theme.of(context);
    var day1 =
        DateFormat.EEEE().format(DateTime.now().add(Duration(hours: 24)));
    var day2 =
        DateFormat.EEEE().format(DateTime.now().add(Duration(hours: 48)));
    var day3 =
        DateFormat.EEEE().format(DateTime.now().add(Duration(hours: 72)));
    return Scaffold(
      backgroundColor: Color(0xffeaeaea),
      appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, SettingsScreen.routeName);
                },
                icon: Icon(
                  Icons.settings,
                  size: 30,
                ))
          ],
          backgroundColor: Color(0xffeaeaea),
          toolbarHeight: 100,
          leading: null,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appLocal.todaysweather,
                style: ApplicationTheme.lightMode.textTheme.titleLarge,
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                child: CircleAvatar(
                  radius: 20,
                  child: Image.asset("assets/images/appbar_icon.png"),
                ),
              ),
            ],
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              WidgetOfData.setData(
                appLocal.temperature,
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${sensorData['temperature'] ?? 'N/A'} ',
                        style: ApplicationTheme.lightMode.textTheme.bodyMedium,
                      ),
                      ImageIcon(AssetImage("assets/images/c_icon.png")),
                    ],
                  ),
                ],
                Colors.white,
                iconPath: "assets/images/temp_icon.png",
              ),
              SizedBox(
                height: 30,
              ),
              WidgetOfData.setData(
                  '',
                  [
                    WidgetOfData.todaysData(
                        appLocal.humidity,
                        "${sensorData['humidity'] ?? 'N/A'}",
                        "assets/images/humidity_icon.png"),
                    WidgetOfData.todaysData(
                        appLocal.rain,
                        "${sensorData['rain'] == 1 ? appLocal.no : sensorData['rain'] == 0 ? appLocal.yes : "N/A"}",
                        "assets/images/raining_icon.png"),
                    WidgetOfData.todaysData(
                        appLocal.windspeed,
                        "${sensorData['windspeed'] ?? 'N/A'}",
                        "assets/images/wind_icon.png"),
                    WidgetOfData.todaysData(
                        appLocal.pressure,
                        "${sensorData['pressure'] ?? 'N/A'}",
                        "assets/images/pressure_icon.png"),
                    WidgetOfData.todaysData(
                        appLocal.airquality,
                        "${sensorData['airquality'] ?? 'N/A'}",
                        "assets/images/air_quality.png"),
                    WidgetOfData.todaysData(
                        appLocal.light,
                        "${sensorData['light'] ?? 'N/A'}",
                        "assets/images/light_icon.png"),
                  ],
                  Colors.white),
              SizedBox(
                height: 30,
              ),
              WidgetOfData.setData(
                  appLocal.probofrain,
                  [
                    Text(
                        style: theme.textTheme.bodyMedium,
                        '${regressionData['rain_probability'] != null ? (100.0 * (1 - regressionData['rain_probability'])).toStringAsFixed(2) : 'N/A'}%'),
                    Text(
                      '${appLocal.rainpredict}: ${regressionData['rain_prediction'] == 1 ? appLocal.no : appLocal.yes}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  Colors.white),
              SizedBox(
                height: 30,
              ),
              Text(
                appLocal.morning,
                style: ApplicationTheme.lightMode.textTheme.titleLarge,
              ),
              SizedBox(
                height: 20,
              ),
              WidgetOfData.setData(
                  appLocal.dayforecast,
                  [
                    WidgetOfData.dataOfNextDays(
                        day1,
                        regressionData['temperature_prediction_day']?['day+1']
                                    ?[0]
                                ?.toStringAsFixed(2) ??
                            "N/A",
                        regressionData['humidity_prediction_day']?['day+1']?[0]
                                ?.toStringAsFixed(2) ??
                            'N/A'),
                    WidgetOfData.dataOfNextDays(
                        day2,
                        regressionData['temperature_prediction_day']?['day+2']
                                    ?[0]
                                ?.toStringAsFixed(2) ??
                            "N/A",
                        regressionData['humidity_prediction_day']?['day+2']?[0]
                                ?.toStringAsFixed(2) ??
                            'N/A'),
                    WidgetOfData.dataOfNextDays(
                        day3,
                        regressionData['temperature_prediction_day']?['day+3']
                                    ?[0]
                                ?.toStringAsFixed(2) ??
                            "N/A",
                        regressionData['humidity_prediction_day']?['day+3']?[0]
                                ?.toStringAsFixed(2) ??
                            'N/A'),
                  ],
                  Colors.white),
              SizedBox(
                height: 30,
              ),
              Text(
                appLocal.evening,
                style: ApplicationTheme.lightMode.textTheme.titleLarge,
              ),
              SizedBox(
                height: 20,
              ),
              WidgetOfData.setData(
                  appLocal.dayforecastnight,
                  [
                    WidgetOfData.dataOfNextDays(
                        day1,
                        regressionData['temperature_prediction_night']
                                    ?['night+1']?[0]
                                ?.toStringAsFixed(2) ??
                            "N/A",
                        regressionData['humidity_prediction_night']?['night+1']
                                    ?[0]
                                ?.toStringAsFixed(2) ??
                            'N/A',
                        Colors.white),
                    WidgetOfData.dataOfNextDays(
                        day2,
                        regressionData['temperature_prediction_night']
                                    ?['night+1']?[0]
                                ?.toStringAsFixed(2) ??
                            "N/A",
                        regressionData['humidity_prediction_night']?['night+2']
                                    ?[0]
                                ?.toStringAsFixed(2) ??
                            'N/A',
                        Colors.white),
                    WidgetOfData.dataOfNextDays(
                        day3,
                        regressionData['temperature_prediction_night']
                                    ?['night+1']?[0]
                                ?.toStringAsFixed(2) ??
                            "N/A",
                        regressionData['humidity_prediction_night']?['night+3']
                                    ?[0]
                                ?.toStringAsFixed(2) ??
                            'N/A',
                        Colors.white),
                  ],
                  Colors.black,
                  color: Colors.white),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRegressionData,
        tooltip: 'Fetch Regression Data',
        child: Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _sensorDataService.dispose();
    super.dispose();
  }
}
