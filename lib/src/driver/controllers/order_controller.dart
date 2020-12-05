import '../../helpers/helper.dart';
import '../../repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../models/order.dart';
import '../repository/order_repository.dart';

class OrderController extends ControllerMVC {
  List<Order> orders = <Order>[];
  bool isWorking = false;
  bool orders_loaded = false;
  GlobalKey<ScaffoldState> scaffoldKey;

  OrderController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    isWorking = Helper.validWorkHours(currentUser.value.work_hours);
  }

  void listenForOrders({String message}) async {
    var driver_ids = [1, int.parse(currentUser.value.id)];
    driver_ids.forEach((element) async {
      final Stream<Order> stream = await getOrders(driver_id: element);
      stream.listen((Order _order) {
        if (currentUser.value.work_hours == '24/7') {
          orders.add(_order);
        } else {
          if ((!orders.contains(_order) && isWorking) || (!orders.contains(_order) && !isWorking && _order.orderStatus.status != "Pending Approval")) {
            if (_order.orderStatus.id == '1' || orders.isEmpty) {
              setState(() {
                orders.add(_order);
              });
            } else {
              for (int i = 0; i < orders.length; i++) {
                if (int.parse(orders.elementAt(i).orderStatus.id) <
                    int.parse(_order.orderStatus.id)) {
                  setState(() {
                    orders.insert(i, _order);
                  });
                }
              }
            }
          }
        }

      }, onError: (a) {
        print(a);
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).verify_your_internet_connection),
        ));
      }, onDone: () {
        setState(() => orders_loaded = true);
        if (message != null) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(message),
            duration: Duration(seconds: 1),
          ));
        }
      });
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
    orders.clear();
    listenForOrders(message: S.of(context).order_refreshed_successfuly);
  }
}
