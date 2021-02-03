import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:saudaghar/src/helpers/maps_util.dart';
import '../models/address.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../../generated/l10n.dart';
import '../helpers/helper.dart';


class _DateTimePickerState extends State<DateTimePicker> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeliveryBottomDetailsWidget(),
    );
  }
}

class DateTimePicker extends StatefulWidget {
  @override
  _DateTimePickerState createState() => _DateTimePickerState();
}

class DeliveryBottomDetailsWidget extends StatefulWidget {
  final DeliveryPickupController con;

  const DeliveryBottomDetailsWidget({Key key, this.con}) : super(key: key);

  _DeliveryBottomDetailsWidget createState() => _DeliveryBottomDetailsWidget();
}


class _DeliveryBottomDetailsWidget extends State<DeliveryBottomDetailsWidget> {
  bool _isVisible = false;
  String _date = "Set Day";
  String _time = "Set Time";
  OverlayEntry loader;

  @override
  void initState() {
    super.initState();
    loader = Helper.overlayLoader(context);
  }


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
            height: 240,
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
                  widget.con.store.id == '0' ? Scheduler() : TimeSlotScheduler(['8am - 10am', '10am - 12pm', '12pm - 2pm']),
                  Expanded(child: SizedBox()),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          S.of(context).subtotal,
                          style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 18)),
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
                          style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 13)),
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
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 10),
                  // Text(
                  //   "*Prices may vary on store receipt but this is official payable amount",
                  //   textAlign: TextAlign.center,
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .caption
                  //       .merge(TextStyle(fontSize: 10)),
                  // ),
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
              Flexible (
                child: SizedBox(width: 10),
              ),
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
              Flexible (
                child: SizedBox(width: 10),
              ),
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


  List<String> dropdown_vals = List<String>();
  String dropdownValue = '';
  Widget TimeSlotScheduler(List<String> timeslots) {
    if (dropdownValue == '') {
      var current_date = DateTime.now().add(Duration(hours: 12));
      List<int> starting_times = [];
      timeslots.forEach((element) {
        int day = 0;
        String start_time = element.split(' - ')[0];
        assert(start_time.contains('am') || start_time.contains('pm'));
        if (start_time.contains('am') || start_time.contains('12pm')) {
          start_time = start_time.replaceAll('am', '');
          start_time = start_time.replaceAll('pm', '');
        } else if (start_time.contains('pm') || start_time.contains('12am')){
          start_time = start_time.replaceAll('am', '');
          start_time = start_time.replaceAll('pm', '');
          start_time = '${(int.tryParse(start_time) + 12)}';
        }
        if (current_date.hour < int.tryParse(start_time)) {
          day = current_date.weekday;
        } else {
          day = current_date.weekday == 7 ? 1 : current_date.weekday + 1;
        }
        dropdown_vals.add('${getDayfromInt(day)}, ${element}');
      });
      dropdownValue = dropdown_vals.first;
    }



    // String dropdownValue = dropdown_vals.first;

    return ButtonTheme(
        minWidth: 10.0,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
          elevation: 4.0,
          onPressed: () {

          },
          child: Container(
            alignment: Alignment.center,
            height: 50.0,
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).accentColor),
              iconSize: 44,
              style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
              underline: Container(
                height: 0,
                color: Theme.of(context).accentColor,
              ),
              onChanged: (String newValue) {
                setState(() => dropdownValue = newValue);
              },
              items: dropdown_vals.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          color: Theme.of(context).primaryColor,
        ));
      Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          color: Theme.of(context).accentColor,
          style: BorderStyle.solid,
          width: 2
        ),
      ),
      child: DropdownButton<String>(
        value: dropdownValue,
        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).accentColor),
        iconSize: 44,
        style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20),
        underline: Container(
          height: 0,
          color: Theme.of(context).accentColor,
        ),
        onChanged: (String newValue) {
          setState(() => dropdownValue = newValue);
        },
        items: dropdown_vals.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ));
  }

  String getDayfromInt(int i) {
    assert(i > 0);
    assert(i < 8);
    switch (i) {
      case 1:
        return 'Monday';
        break;
      case 2:
        return 'Tuesday';
        break;
      case 3:
        return 'Wednesday';
        break;
      case 4:
        return 'Thursday';
        break;
      case 5:
        return 'Friday';
        break;
      case 6:
        return 'Saturday';
        break;
      case 7:
        return 'Sunday';
        break;
    }
  }

  Future<void> checkout() async {
    if (widget.con.selectedAddress) {
      Overlay.of(context).insert(loader);
      Address store_address = new Address(
          long: double.tryParse(widget.con.carts[0].food.restaurant.longitude),
          lat: double.tryParse(widget.con.carts[0].food.restaurant.latitude)
      );
      // Address curr_address = new Address(address: result.address,
      //                                     long: result.latLng.longitude,
      //                                     lat: result.latLng.latitude
      //                             );
      bool within_range = await MapsUtil.withinRange(settingsRepo.deliveryAddress.value, store_address,
          widget.con.carts[0].food.restaurant.deliveryRange);
      Helper.hideLoader(loader);
      if (!within_range) {
        showDialog(
            context: context,
            builder: (context) => updateOrderDialog(settingsRepo.deliveryAddress.value)
        );
      } else {
        if (widget.con.store.id == '0') {
          timeslot_time.value = null;
          if (!_isVisible || (_date == "Set Day" && _time == "Set Time")) {
            widget.con.goCheckout(context);
          } else if (_isVisible
              && ((_date == "Set Day" && _time != "Set Time")
                  || (_date != "Set Day" && _time == "Set Time"))) {

            widget.con.showSnackBar("Please specify both date and time.");

          } else {
            _time = _time.replaceAll(" ", "");
            String year = _date.split('/')[2];
            String month = int.parse(_date.split('/')[1]) < 10 ? '0' + _date.split('/')[1] : _date.split('/')[1];
            String day = int.parse(_date.split('/')[0]) < 10 ? '0' + _date.split('/')[0] : _date.split('/')[0];
            String hour = int.parse(_time.trim().split(':')[0]) < 10 ? '0' + _time.trim().split(':')[0] : _time.trim().split(':')[0];
            String minute = _time.trim().split(':')[1];
            DateTime scheduled_time = DateTime.parse(year + month + day + 'T' + hour + minute + '00');
            currentCart_time.value = scheduled_time;
            var desc = widget.con.carts[0].food?.restaurant?.description;
            if (desc != '24/7') {
              var now = int.parse(_time.trim().split(':')[0]) + int.parse(_time.trim().split(':')[1]) / 100;
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
                closeTime_hour = 12 + int.parse(times[1].replaceAll("p", "").replaceAll("a", ""));
              } else if ((times[1].endsWith('a') &&
                  int.parse(times[1].replaceAll("a", "")) > openTime_hour) ||
                  (times[1].contains("12") && times[1].endsWith("p"))) {
                closeTime_hour = int.parse(times[1].replaceAll("p", "").replaceAll("a", ""));
              } else if (times[1].endsWith("a") &&
                  int.parse(times[1].replaceAll("a", "")) < openTime_hour) {
                closeTime_hour = 24 + int.parse(times[1].replaceAll("a", ""));
              }

              if (now >= (openTime_hour + openTime_min / 100) && now <= (closeTime_hour + closeTime_min / 100)) {
                // currentCart_time.value = _date + " " + _time;
                widget.con.goCheckout(context);
              } else {
                desc = desc
                    .replaceAll("<p>", "")
                    .replaceAll("</p>", "")
                    .replaceAll("-", " - ");
                widget.con.showSnackBar("Delivery not available at that time. Timings: ${desc}.");
              }

            } else {
              widget.con.goCheckout(context);
            }
          }
        } else {
          if (dropdownValue == 'Select Delivery Timeslot') {
            widget.con.showSnackBar("Please select a timeslot for delivery");
          } else {
            timeslot_time.value = dropdownValue;
            currentCart_time.value = null;
            widget.con.goCheckout(context);
          }
        }
      }
    } else {
      widget.con.showSnackBar(S.of(context).please_select_delivery);
    }

  }

  Widget updateOrderDialog(Address curr_address) {
    String address = '';
    if (curr_address.address == null) {
      address = "this address.\n\n";
    } else {
      print(curr_address.address);
      address = "address: \n\n'${curr_address.address}' \n\n";
    }
    return AlertDialog(
      title:  Wrap(
        spacing: 10,
        children: <Widget>[
          Icon(Icons.report, color: Colors.orange),
          Text(
            'Store too far',
            style: TextStyle(color: Colors.orange, fontSize: 20),
          ),
        ],
      ),
      content: Text("Unfortunately ${widget.con.carts.first.food.restaurant.name} does not deliver to ${address} We aim to expand our services in the near future. Feel free to  contact our support team for more information."),
      actions: <Widget>[
        FlatButton(
          child: new Text(
              S.of(context).dismiss),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

}

