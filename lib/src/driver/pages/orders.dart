import 'package:saudaghar/src/repository/user_repository.dart';

import '../elements/NotWorkingWidget.dart';
import '../elements/OrderItemWidget.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../repository/order_repository.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrdersWidget extends StatefulWidget with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> {
  var timer;
  _OrdersWidgetState() : super(OrderController()) {
    con.value = controller;
  }

  @override
  void initState() {
    super.initState();
    con.value.listenForOrders();
    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => autoOrderRefresh());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.resumed:
        setState(() => con.value.app_paused = false);
        print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        setState(() => con.value.app_paused = true);
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  void autoOrderRefresh() {
    if (mounted && context != null) {
      print('---Refreshed---');
      con.value.refreshOrders();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: con.value.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).orders,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: con.value.refreshOrders,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 10),
          children: <Widget>[
            !currentUser.value.available && con.value.orders.isEmpty && currentUser.value.work_hours != '24/7'
                ? NotWorkingWidget()
                : !con.value.orders_loaded || con.value.orders.isEmpty
                    ? EmptyOrdersWidget()
                    : ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: con.value.orders.length,
                        itemBuilder: (context, index) => OrderItemWidget(order: con.value.orders.elementAt(index)),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 20);
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
