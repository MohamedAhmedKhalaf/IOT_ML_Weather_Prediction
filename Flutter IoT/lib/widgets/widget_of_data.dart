import 'package:flutter/material.dart';
import 'package:project_iot/core/theme/theme.dart';

class WidgetOfData {
  static Widget dataOfNextDays(String day, String temp, String hum,
      [Color _color = Colors.black]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: ApplicationTheme.lightMode.textTheme.bodyMedium
              ?.copyWith(color: _color),
        ),
        Row(
          children: [
            Text(
              temp,
              style: ApplicationTheme.lightMode.textTheme.bodySmall
                  ?.copyWith(color: _color),
            ),
            SizedBox(
              width: 5,
            ),
            ImageIcon(
              AssetImage("assets/images/celsius_icon.png"),
              color: Colors.red,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "/ $hum",
              style: ApplicationTheme.lightMode.textTheme.bodySmall
                  ?.copyWith(color: _color),
            ),
            SizedBox(
              width: 5,
            ),
            ImageIcon(
              AssetImage("assets/images/humidity_icon.png"),
              color: Colors.blue,
            )
          ],
        )
      ],
    );
  }

  static Widget todaysData(String title, String data, String iconPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: ApplicationTheme.lightMode.textTheme.bodyMedium,
        ),
        Row(
          children: [
            Text(
              data,
              style: ApplicationTheme.lightMode.textTheme.bodySmall,
            ),
            SizedBox(
              width: 5,
            ),
            ImageIcon(
              AssetImage(iconPath),
              color: Colors.blue,
            ),
          ],
        )
      ],
    );
  }

  static Widget setData(
      String title, List<Widget> widgets, Color colorOfContainer,
      {Color color = Colors.black, String? iconPath}) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 0.6),
                blurRadius: 9.0,
              ),
            ],
            color: colorOfContainer,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: ApplicationTheme.lightMode.textTheme.titleLarge
                        ?.copyWith(color: color)),
                if (iconPath != null)
                  ImageIcon(
                    AssetImage(iconPath),
                    color: Colors.red,
                  )
              ],
            ),
            ...widgets,
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
