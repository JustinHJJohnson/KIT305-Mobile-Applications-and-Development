import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, textAlign: TextAlign.center),
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(10),
    backgroundColor: Theme.of(context).primaryColor,
  ));
}