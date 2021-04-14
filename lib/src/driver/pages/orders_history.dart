import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import 'package:intl/intl.dart' show DateFormat;

class OrdersHistoryWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersHistoryWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersHistoryWidgetState createState() => _OrdersHistoryWidgetState();
}

class _OrdersHistoryWidgetState extends StateMVC<OrdersHistoryWidget> {
  OrderController _con;
  final _currentDate = DateTime.now();
  _OrdersHistoryWidgetState() : super(OrderController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.start_time = _currentDate.subtract(Duration(days: 7));
    _con.end_time = _currentDate;
    // _con.listenForOrdersHistory();
    _con.listenForOrdersHistoryWithinRange();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Scaffold(
      key: _con.scaffoldKey,
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
          S.of(context).orders_history,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DateRangeWidget(
                date: _con.start_time,
                currentDate: _currentDate,
                onChanged: (_date) {
                  if (_con.start_time != _date) {
                    setState(() => _con.start_time = _date);
                    _con.listenForOrdersHistoryWithinRange();
                  }
                }
              ),
              Text("to", style: Theme.of(context).textTheme.headline5),
              DateRangeWidget(
                date: _con.end_time,
                currentDate: _currentDate,
                onChanged: (_date) {
                  if (_con.end_time != _date) {
                    setState(() => _con.end_time = _date);
                    _con.listenForOrdersHistoryWithinRange();
                  }
                }
              ),
            ],
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              primary: true,
              padding: EdgeInsets.symmetric(vertical: 10),
              children: <Widget>[
                _con.orders.isEmpty
                  ? EmptyOrdersWidget()
                  : ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.orders.length,
                      itemBuilder: (context, index) {
                        var _order = _con.orders.elementAt(index);
                        return OrderItemWidget(order: _order, hero_tag: 'history');
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 20);
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}



class DateRangeWidget extends StatelessWidget {
  const DateRangeWidget({Key key, @required this.date, @required this.currentDate, @required this.onChanged}) : super(key: key);

  final DateTime date;
  final DateTime currentDate;
  final ValueChanged<DateTime> onChanged;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 4.0,
              onPressed: () {
                DatePicker.showDatePicker(context,
                    theme: DatePickerTheme(
                      itemHeight: 100.0,
                    ),
                    showTitleActions: true,
                    minTime: DateTime(currentDate.year - 1, currentDate.month, currentDate.day),
                    maxTime: currentDate,
                    onConfirm: (_date) => onChanged(_date),
                    currentTime: date, locale: LocaleType.en);
              },
              child: Container(
                alignment: Alignment.center,
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                size: 18.0,
                                color: Theme.of(context).hintColor,
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }




}

