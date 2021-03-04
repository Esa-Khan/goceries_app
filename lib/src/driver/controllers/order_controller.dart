import '../../repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {
  List<Order> orders = <Order>[];
  bool orders_loaded = false;
  bool app_paused = false;
  GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    getDriverAvail();
    // Helper.validWorkHours(currentUser.value.work_hours);
  }

  void listenForOrders({String message}) async {
    final Stream<Order> stream = await getOrders();
    stream.listen((Order _order) {
      bool repeated_order = false;
      for (int i = 0; i < orders.length; i ++) {
        repeated_order = _order.id == orders[i].id;
        if (repeated_order) break;
      }
      if (!repeated_order) setState(() => orders.add(_order));
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      setState(() => orders_loaded = true);
      if (message != null && !app_paused) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          duration: Duration(milliseconds: 500),
        ));
      }
    });

  }

  void listenForOrdersHistory({String message}) async {
    final Stream<Order> stream = await getOrdersHistory();
    stream.listen((Order _order) {
      setState(() {
        orders.add(_order);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshOrdersHistory() async {
    orders.clear();
    listenForOrdersHistory(message: S.of(context).order_refreshed_successfuly);
  }

  Future<void> refreshOrders() async {
    getDriverAvail();
    orders.clear();
    getDriverAvail().then((value) => setState(() => currentUser.value));
    listenForOrders(message: S.of(context).order_refreshed_successfuly);
  }
}
