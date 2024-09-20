import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnackBarService {
  static void successMessage(String msg) {
    BotToast.showCustomNotification(
        toastBuilder: (void Function() cancelFun) {
          return Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(left: 24, right: 24),
              height: msg.length > 80 ? 150 : 95,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.all(Radius.circular(14))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      msg,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed:
                        cancelFun, // Dismiss the toast when the close button is pressed
                  ),
                ],
              ),
            ),
          );
        },
        duration: Duration(seconds: 4),
        dismissDirections: [DismissDirection.endToStart]);
  }

  static void fieldMessage(String msg) {
    BotToast.showCustomNotification(
        toastBuilder: (void Function() cancelFun) {
          return Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(left: 24, right: 24),
              height: msg.length > 80 ? 150 : 95,
              width: double.maxFinite,
              decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.all(Radius.circular(14))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      msg,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        duration: Duration(seconds: 4),
        dismissDirections: [DismissDirection.endToStart]);
  }
}
