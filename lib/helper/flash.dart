import 'package:flutter/material.dart';

enum FlashType { SUCCESS, ERROR, WARNING, INFO }

class Flash {
  String message;
  FlashType type;

  Flash({this.message, this.type});

  get color {
    switch (this.type) {
      case FlashType.SUCCESS:
        return Colors.lightGreen;
      case FlashType.ERROR:
        return Colors.red;
      case FlashType.WARNING:
        return Colors.orangeAccent;
      case FlashType.INFO:
        return Colors.lightBlueAccent;
    }
  }
}