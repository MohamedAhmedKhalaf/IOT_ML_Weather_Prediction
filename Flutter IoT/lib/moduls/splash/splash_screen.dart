import 'dart:async';
import 'package:flutter/material.dart';

import '../login/login_screen.dart';

class SplashScreen extends StatelessWidget {
  static const routeName = "splash_screen";

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    });
    return Scaffold(
        backgroundColor: Color(0xff1c2120),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Image.asset(
              "assets/images/splach_icon.png",
            ),
          ),
        ));
  }
}
