import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  String labelText;
  IconButton? suffix_Icon;
  bool sec;
  final FormFieldValidator<String>? valdiator;

  CustomTextFormField(
      {required this.controller,
      required this.title,
      this.valdiator,
      required this.labelText,
      this.suffix_Icon,
      this.sec = false});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: valdiator,
      obscureText: sec,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: suffix_Icon,
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        hintText: title,
      ),
    );
  }
}
