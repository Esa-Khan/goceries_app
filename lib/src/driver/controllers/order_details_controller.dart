import 'package:saudaghar/src/models/address.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../models/order.dart';
import '../repository/order_repository.dart';
import '../../repository/settings_repository.dart';

class OrderDetailsController extends ControllerMVC {
  Order order;
  GlobalKey<ScaffoldState> scaffoldKey;

  OrderDetailsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForOrder({String id, String message}) async {
    final Stream<Order> stream = await getOrder(id);
    stream.listen((Order _order) {
      setState(() => order = _order);
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

  Future<void> refreshOrder() async {
    listenForOrder(id: order.id, message: S.of(context).order_refreshed_successfuly);
  }

  void doDeliveredOrder(Order _order) async {
    deliveredOrder(_order).then((value) {
      setState(() {
        this.order.orderStatus.id = '5';
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('The order deliverd successfully to client'),
      ));
    });
  }

  Future<void> updateOrder(Order _order) async {
    if (_order.orderStatus.id == '1' && _order.driver_id == 1) {
      _order.driver_id = int.parse(currentUser.value.id);
    }
    await deliveredOrder(_order).then((value) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Order Status Updated'),
      ));
    });
  }


  Future<void> openMap(Address order_address) async {
    await getCurrentLocation();
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=${order_address.latitude},${order_address.longitude}';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

}
