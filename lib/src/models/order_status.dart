import 'dart:ui';

import 'package:flutter/material.dart';

import '../helpers/custom_trace.dart';

class OrderStatus {
  String id;
  String status;
  Color status_color;

  OrderStatus();

  OrderStatus.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      status = jsonMap['status'] != null ? jsonMap['status'] : '';
      switch(id) {
        case '1':
          status_color = Colors.green;
          break;
        case '2':
          status_color = Colors.orange;
          break;
        case '3':
          status_color = Colors.deepOrange;
          break;
        case '4':
          status_color = Colors.red;
          break;
        case '5':
          status_color = Colors.lightBlue;
          break;
        default:

          break;
            }
    } catch (e) {
      id = '';
      status = '';
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
}
