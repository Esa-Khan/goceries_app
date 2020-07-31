import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:food_delivery_app/src/controllers/delivery_pickup_controller.dart';
import 'package:food_delivery_app/src/pages/delivery_pickup.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';
import '../helpers/app_config.dart' as config;
import 'package:food_delivery_app/src/repository/settings_repository.dart';


class CartBottomDetailsWidget extends StatefulWidget{
  final con;

  const CartBottomDetailsWidget ({ Key key, this.con }): super(key: key);

  _CartBottomDetailsWidget createState()=> _CartBottomDetailsWidget();
}

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CartBottomDetailsWidget(),
    );
  }
}


class _CartBottomDetailsWidget extends State<CartBottomDetailsWidget>{
  bool _isVisible = true;
  String _date = "Set Day";
  String _time = "Set Time";


  void showScheduler() {
    setState(() {
      _isVisible = !_isVisible;
      if (!_isVisible){
        _date = "Set Day";
        _time = "Set Time";
      }

    });

  }

  @override
  Widget build(BuildContext context) {
    return widget.con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
            height: widget.con.runtimeType == DeliveryPickupController ? 300 : 230,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(0.55),
                      offset: Offset(0, -4),
                      blurRadius: 5.0)
                ]),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  widget.con.runtimeType == DeliveryPickupController
                      ? Visibility(
                          visible: _isVisible,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    elevation: 4.0,
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      showScheduler();
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        height: 50.0,
                                        child: Text(
                                          "Schedule Pickup/Delivery for Later",
                                          style: TextStyle(
                                              color: Theme.of(context).accentColor),
                                        )
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    replacement: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                                    minTime: DateTime.now(),
                                    maxTime: DateTime(DateTime.now().year, DateTime.now().month + 1, 31), onConfirm: (date) {
                                      _date = '${date.day}/${date.month}/${date.year}';
                                      setState(() {});
                                    },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.en);
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
                                                color:
                                                Theme.of(context).accentColor,
                                              ),
                                              Text(
                                                " $_date",
                                                style: TextStyle(
                                                    color: Theme.of(context).accentColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0),
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
                            SizedBox(height: 85, width: 10),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              elevation: 4.0,
                              onPressed: () {
                                DatePicker.showTimePicker(context,
                                    theme: DatePickerTheme(
                                      containerHeight: 190.0,
                                    ),
                                    showTitleActions: true,
                                    onConfirm: (time) {
                                      _time = '${time.hour} : ${time.minute.toString().padLeft(2, '0')}';
                                      setState(() {});
                                    },
                                    currentTime: DateTime.now(),
                                    locale: LocaleType.en,
                                    showSecondsColumn: false);
                                setState(() {});
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
                                                Icons.access_time,
                                                size: 18.0,
                                                color:
                                                Theme.of(context).accentColor,
                                              ),
                                              Text(
                                                " $_time",
                                                style: TextStyle(
                                                    color: Theme.of(context).accentColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0),
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
                            SizedBox(height: 85, width: 10),
                            ButtonTheme(
                                minWidth: 10.0,
                                child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100.0)),
                              elevation: 4.0,
                              onPressed: () {
                                showScheduler();
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
                                                Icons.highlight_off,
                                                size: 40.0,
                                                color:
                                                Theme.of(context).accentColor,
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
                            )
                          )
                          ],
                        ),
                      ),
                    ),
                  )
                      : SizedBox(height: 0),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      Helper.getPrice(widget.con.subTotal, context,
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
                      if (Helper.canDelivery(widget.con.carts[0].food.restaurant,
                          carts: widget.con.carts) && widget.con.subTotal < setting.value.deliveryFeeLimit)
                        Helper.getPrice(
                            widget.con.carts[0].food.restaurant.deliveryFee, context,
                            style: Theme.of(context).textTheme.subtitle1)
                      else
                        Helper.getPrice(0, context,
                            style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
//                  Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: Text(
//                          '${S.of(context).tax} (${widget.con.carts[0].food.restaurant.defaultTax}%)',
//                          style: Theme.of(context).textTheme.bodyText1,
//                        ),
//                      ),
//                      Helper.getPrice(widget.con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
//                    ],
//                  ),
                  SizedBox(height: 20),
                  Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: MediaQuery.of(context).size.height/12,
                        child: FlatButton(
                          onPressed: () {
                            if (widget.con.runtimeType == CartController){
                              widget.con.goCheckout(context);
                            } else if (_isVisible || _date == "Set Day" || _date == "Set Time") {
                              widget.con.goCheckout(context);
                            } else {
                              widget.con.goCheckout(context, _date + " " + _time);
                            }
                          },
                          disabledColor:
                              Theme.of(context).focusColor.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                          color: !widget.con.carts[0].food.restaurant.closed
                              ? Theme.of(context).accentColor
                              : Theme.of(context).focusColor.withOpacity(0.5),
                          shape: StadiumBorder(),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              S.of(context).checkout,
//                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodyText1.merge(
                                  TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
                            ),
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Helper.getPrice(
                          widget.con.total,
                          context,
                          style: Theme.of(context).textTheme.headline4.merge(
                              TextStyle(color: Theme.of(context).primaryColor)),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    "*Prices may vary on store receipt but this is official payable amount",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption.merge(
                        TextStyle(color: Theme.of(context).accentColor)),
                  ),
                ],
              ),
            ),
          );
  }


}
