import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';

class DeliveryBottomDetailsWidget extends StatefulWidget {
  final con;

  const DeliveryBottomDetailsWidget({Key key, this.con}) : super(key: key);

  _DeliveryBottomDetailsWidget createState() => _DeliveryBottomDetailsWidget();
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
      home: DeliveryBottomDetailsWidget(),
    );
  }
}

class _DeliveryBottomDetailsWidget extends State<DeliveryBottomDetailsWidget> {
  bool _isVisible = false;
  String _date = "Set Day";
  String _time = "Set Time";

  void showScheduler() {
    setState(() {
      _isVisible = !_isVisible;
      if (!_isVisible) {
        _date = "Set Day";
        _time = "Set Time";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.con.carts.isEmpty
        ? const SizedBox()
        : Container(
            height: 250,
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
                  Scheduler(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .merge(TextStyle(fontSize: 18)),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .merge(TextStyle(fontSize: 13)),
                        ),
                      ),
                      if (Helper.canDelivery(
                              widget.con.carts[0].food.restaurant,
                              carts: widget.con.carts) &&
                          widget.con.subTotal < settingsRepo.setting.value.deliveryFeeLimit)
                        Helper.getPrice(
                            widget.con.carts[0].food.restaurant.deliveryFee,
                            context,
                            style: Theme.of(context).textTheme.subtitle1)
                      else
                        Helper.getPrice(0, context,
                            style: Theme.of(context).textTheme.subtitle1)
                    ],
                  ),
                  SizedBox(height: 20),

                  Stack(
                    fit: StackFit.loose,
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 60,
                        child: FlatButton(
                            onPressed: () => checkout(),
                            disabledColor:
                                Theme.of(context).focusColor.withOpacity(0.5),
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 25),
                            color: !widget.con.carts[0].food.restaurant.closed
                                ? Theme.of(context).accentColor
                                : Theme.of(context).focusColor.withOpacity(0.5),
                            shape: StadiumBorder(),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Next',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .merge(TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 20)),
                              ),
                            )),
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
                  SizedBox(height: 10),
                  Text(
                    "*Prices may vary on store receipt but this is official payable amount",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .merge(TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ),
          );
  }

  Widget Scheduler() {
    return Visibility(
      visible: !_isVisible,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
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
                      style: TextStyle(color: Theme.of(context).accentColor),
                    )),
              ),
            ],
          ),
        ),
      ),
      replacement: Padding(
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
                      minTime: DateTime.now(),
                      maxTime: DateTime(
                          DateTime.now().year, DateTime.now().month + 1, 31),
                      onConfirm: (date) {
                    _date = '${date.day}/${date.month}/${date.year}';
                    setState(() {});
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
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
                                  color: Theme.of(context).accentColor,
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
              SizedBox(width: 10),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                elevation: 4.0,
                onPressed: () {
                  DatePicker.showTimePicker(context,
                      theme: DatePickerTheme(
                        containerHeight: 190.0,
                      ),
                      showTitleActions: true, onConfirm: (time) {
                    _time =
                        '${time.hour} : ${time.minute.toString().padLeft(2, '0')}';
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
                                  color: Theme.of(context).accentColor,
                                ),
                                Text(
                                  " $_time",
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
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
              SizedBox(width: 10),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.highlight_off,
                                      size: 40.0,
                                      color: Theme.of(context).accentColor,
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
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void checkout() {
    if (!_isVisible || (_date == "Set Day" && _time == "Set Time")) {
      widget.con.goCheckout(context);
    } else if (_isVisible &&
        ((_date == "Set Day" && _time != "Set Time") ||
            (_date != "Set Day" && _time == "Set Time"))) {
      widget.con.showSnackToSelectBothTimeAndDate();
    } else {
      _time = _time.replaceAll(" ", "");
      String year = _date.split('/')[2];
      String month = _date.split('/')[1];
      String day = _date.split('/')[0];
      String hour = _time.trim().split(':')[0];
      String minute = _time.trim().split(':')[1];
      DateTime scheduled_time =
          DateTime.tryParse(year + month + day + 'T' + hour + minute);
      currentCart_time.value = scheduled_time;

      var desc = widget.con.carts[0].food?.restaurant?.description;
      if (desc == '24/7') {
        widget.con.goCheckout(context);
      } else {
        var now = int.parse(_time.trim().split(':')[0]) +
            int.parse(_time.trim().split(':')[1]) / 100;

        var times = desc
            .replaceAll(" ", "")
            .replaceAll("m", "")
            .replaceAll("<p>", "")
            .replaceAll("</p>", "")
            .split('-');
        var openTime_hour = -1,
            closeTime_hour = -1,
            openTime_min = 0,
            closeTime_min = 0;

        if (times[0].contains(":")) {
          openTime_min = int.parse(times[0]
              .substring(times[0].indexOf(':') + 1, times[0].length - 1));
          times[0] = times[0].replaceAll(":" + openTime_min.toString(), "");
        }

        if (times[0].endsWith('a') ||
            (times[1].contains("12") && times[1].endsWith("p"))) {
          openTime_hour =
              int.parse(times[0].replaceAll("p", "").replaceAll("a", ""));
        } else if (times[0].endsWith('p') ||
            (times[1].contains("12") && times[1].endsWith("a"))) {
          openTime_hour =
              12 + int.parse(times[0].replaceAll("p", "").replaceAll("a", ""));
        }

        if (times[1].contains(":")) {
          closeTime_min = int.parse(times[1]
              .substring(times[1].indexOf(':') + 1, times[1].length - 1));
          times[1] = times[1].replaceAll(":" + closeTime_min.toString(), "");
        }

        if (times[1].endsWith('p') ||
            (times[1].contains("12") && times[1].endsWith("a"))) {
          closeTime_hour =
              12 + int.parse(times[1].replaceAll("p", "").replaceAll("a", ""));
        } else if ((times[1].endsWith('a') &&
                int.parse(times[1].replaceAll("a", "")) > openTime_hour) ||
            (times[1].contains("12") && times[1].endsWith("p"))) {
          closeTime_hour =
              int.parse(times[1].replaceAll("p", "").replaceAll("a", ""));
        } else if (times[1].endsWith("a") &&
            int.parse(times[1].replaceAll("a", "")) < openTime_hour) {
          closeTime_hour = 24 + int.parse(times[1].replaceAll("a", ""));
        }

        if (now >= (openTime_hour + openTime_min / 100) &&
            now <= (closeTime_hour + closeTime_min / 100)) {
          // currentCart_time.value = _date + " " + _time;
          widget.con.goCheckout(context);
        } else {
          desc = desc
              .replaceAll("<p>", "")
              .replaceAll("</p>", "")
              .replaceAll("-", " - ");
          widget.con.showTimingSnack(desc);
        }
      }
    }
  }
}
