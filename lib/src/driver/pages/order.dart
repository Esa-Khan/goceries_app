import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../generated/l10n.dart';
import '../../helpers/helper.dart';
import '../../models/route_argument.dart';
import '../controllers/order_details_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FoodOrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrderWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  OrderWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _OrderWidgetState createState() {
    return _OrderWidgetState();
  }
}


class _OrderWidgetState extends StateMVC<OrderWidget> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _tabIndex = 0;
  OrderDetailsController _con;

  _OrderWidgetState() : super(OrderDetailsController()) {
    _con = controller;
  }

  int dropDownValue = 0;
  List<String> orderStatuses = ['Pending Approval', 'Accepted', 'Being Bought', 'On the Way', 'Delivered'];
  bool setStatus = true;

  @override
  void initState() {
    _con.listenForOrder(id: widget.routeArgument.id);
    _tabController = TabController(length: 2, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_con.order != null && setStatus)
      dropDownValue = int.parse(_con.order.orderStatus.id) - 1;
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      bottomNavigationBar: OrderUpdateBottomNav(),
      body: _con.order == null
          ? CircularLoadingWidget(height: 400)
          : CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                snap: true,
                floating: true,
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: Text(
                  S.of(context).order_details,
                  style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
                ),
                actions: <Widget>[
                  new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
                ],
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    margin: EdgeInsets.only(top: 95, bottom: 65),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).order_id + ": #${_con.order.id}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.headline4,
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm').format(_con.order.dateTime),
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    _con.order.scheduled_time != "Deliver Now" && _con.order.scheduled_time != "null" && _con.order.scheduled_time != null
                                        ? Text("Deliver at: ${_con.order.scheduled_time}",
                                                style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).accentColor))
                                        : Text("Deliver Now",
                                        style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).accentColor)),
                                    // _con.order.hint != "null"
                                    //     ? Text("Check Hint",
                                    //             style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).accentColor))
                                    //     : const SizedBox()
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Helper.getPrice(Helper.getTotalOrdersPrice(_con.order), context, style: Theme.of(context).textTheme.headline4),
                                  Text(
                                    _con.order.payment?.method ?? S.of(context).cash_on_delivery,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                  Text(
                                    S.of(context).items + ': ' + _con.order.foodOrders?.length?.toString() ?? 0,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                ),
                bottom: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.symmetric(horizontal: 10),
                    unselectedLabelColor: Theme.of(context).accentColor,
                    labelColor: Theme.of(context).primaryColor,
                    indicator: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Theme.of(context).accentColor),
                    tabs: [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50), border: Border.all(color: Theme.of(context).accentColor.withOpacity(0.2), width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).ordered_foods),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50), border: Border.all(color: Theme.of(context).accentColor.withOpacity(0.2), width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).customer),
                          ),
                        ),
                      ),
                    ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Offstage(
                    offstage: 0 != _tabIndex,
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 20, bottom: 50),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.order.foodOrders?.length ?? 0,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        return FoodOrderItemWidget(heroTag: 'my_orders', order: _con.order, foodOrder: _con.order.foodOrders.elementAt(index));
                      },
                    ),
                  ),
                  Offstage(
                    offstage: 1 != _tabIndex,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).fullName,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.user.name,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  disabledColor: Theme.of(context).focusColor.withOpacity(0.4),
                                  //onPressed: () {
//                                    Navigator.of(context).pushNamed('/Profile',
//                                        arguments: new RouteArgument(param: _con.order.deliveryAddress));
                                  //},
                                  child: Icon(
                                    Icons.person,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  color: Theme.of(context).accentColor.withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).deliveryAddress,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.deliveryAddress?.address ?? S.of(context).address_not_provided_please_call_the_client,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  disabledColor: Theme.of(context).focusColor.withOpacity(0.4),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/Pages', arguments: new RouteArgument(id: '3', param: _con.order));
                                  },
                                  child: Icon(
                                    Icons.directions,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  color: Theme.of(context).accentColor.withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).phoneNumber,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.user.phone,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    launch("tel:${_con.order.user.phone}");
                                  },
                                  child: Icon(
                                    Icons.call,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  color: Theme.of(context).accentColor.withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Schduled Time
                        _con.order.scheduled_time == "Deliver Now" || _con.order.scheduled_time == "null" || _con.order.scheduled_time == null
                            ? const SizedBox()
                            : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Scheduled Time",
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.scheduled_time,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                    padding: EdgeInsets.all(0),
                                    disabledColor: Theme.of(context).focusColor.withOpacity(0.4),
                                    child: Icon(
                                      Icons.timer,
                                      color: Theme.of(context).primaryColor,
                                      size: 24,
                                    ),
                                    color: Theme.of(context).accentColor.withOpacity(0.9),
                                    shape: StadiumBorder()
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Hint section
                        _con.order.hint == "null" || _con.order.hint == null
                        ? const SizedBox()
                        : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Extra Order Details",
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.caption,
                                    ),
                                    Text(
                                      _con.order.hint,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FlatButton(
                                  padding: EdgeInsets.all(0),
                                  disabledColor: Theme.of(context).focusColor.withOpacity(0.4),
                                  child: Icon(
                                    Icons.description,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  color: Theme.of(context).accentColor.withOpacity(0.9),
                                  shape: StadiumBorder()
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ]),
    );
  }

  Widget OrderUpdateBottomNav() {
    return _con.order == null
        ? Center(
            child: SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(strokeWidth: 8)))
        : Container(
            height: _con.order.orderStatus.id == '5' ? 140 : 195,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.15),
                      offset: Offset(0, -2),
                      blurRadius: 5.0)
                ]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(
                          Helper.getSubTotalOrdersPrice(_con.order), context,
                          style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).delivery_fee,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(_con.order.deliveryFee, context,
                          style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  Divider(height: 5),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).total,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                      Helper.getPrice(
                          Helper.getTotalOrdersPrice(_con.order), context,
                          style: Theme.of(context).textTheme.headline6)
                    ],
                  ),
                  SizedBox(height: _con.order.orderStatus.id == '5' ? 0 : 20),
                  _con.order.orderStatus.id == '5'
                      ? SizedBox(height: 0)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 15.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(
                                      color: Theme.of(context).accentColor,
                                      style: BorderStyle.solid,
                                      width: 3.80),
                                ),
                                child: DropdownButton<String>(
                                  isDense: true,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  iconSize: 40,
                                  elevation: 16,
                                  style: Theme.of(context).textTheme.headline6.apply(
                                  color: Theme.of(context).accentColor),
                                  onChanged: (String changedValue) {
                                  },
                                  value: orderStatuses.elementAt(dropDownValue),
                                  items: orderStatuses.map<DropdownMenuItem<String>>(
                                    (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: SizedBox()
                            ),
                            Expanded(
                              flex: 4,
                              child: FlatButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => updateOrderDialog());
                                },
                                padding: EdgeInsets.symmetric(vertical: 14),
                                color: Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Text(
                                  S.of(context).update,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              )
                            )
                          ]),
                  SizedBox(height: _con.order.orderStatus.id == '5' ? 0 : 10),
                ],
              ),
            ),
          );
  }

  Widget updateOrderDialog() {
    return AlertDialog(
      title: Text(S.of(context).delivery_confirmation),
      content: Text(S.of(context).are_you_sure_you_want_to_update_the_order),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        FlatButton(
          child: new Text(
              S.of(context).dismiss),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: new Text(
              S.of(context).confirm),
          onPressed: () {
            _con.updateOrder(_con.order).whenComplete(() {
              _con.refreshOrder().whenComplete(() {
                setState(() => dropDownValue++);
                // Not to re-initialize dropdown menu display
                setStatus = false;
                Navigator.of(context).pop();
              });
            });
          },
        ),
      ],
    );
  }

}


