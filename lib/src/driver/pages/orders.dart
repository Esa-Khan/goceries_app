import '../elements/NotWorkingWidget.dart';
import '../elements/OrderItemWidget.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../elements/EmptyOrdersWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrdersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> {
  var timer;
  _OrdersWidgetState() : super(OrderController()) {
    orderRepo.con.value = controller;
  }

  @override
  void initState() {
    super.initState();
    orderRepo.con.value.listenForOrders();
    // autoOrderRefresh();
    timer = Timer.periodic(Duration(seconds: 100), (Timer t) => autoOrderRefresh());
  }

  void autoOrderRefresh() {
    if (mounted && context != null) {
      print('---Refreshed---');
      orderRepo.con.value.refreshOrders();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: orderRepo.con.value.scaffoldKey,
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
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: orderRepo.con.value.refreshOrders,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 10),
          children: <Widget>[
            !orderRepo.con.value.isWorking
                ? NotWorkingWidget()
                : !orderRepo.con.value.orders_loaded || orderRepo.con.value.orders.isEmpty
                    ? EmptyOrdersWidget()
                    : ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: orderRepo.con.value.orders.length,
                        itemBuilder: (context, index) => OrderItemWidget(expanded: false, order: orderRepo.con.value.orders.elementAt(index)),
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
