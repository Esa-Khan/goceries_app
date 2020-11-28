import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:saudaghar/src/controllers/delivery_pickup_controller.dart';
import 'package:saudaghar/src/repository/cart_repository.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';
import 'package:saudaghar/src/repository/settings_repository.dart';
import 'OrderNotesWidget.dart';


class CheckoutBottomDetailsWidget extends StatefulWidget{
  final con;

  const CheckoutBottomDetailsWidget ({ Key key, this.con }): super(key: key);

  _CheckoutBottomDetailsWidget createState()=> _CheckoutBottomDetailsWidget();
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
      home: CheckoutBottomDetailsWidget(),
    );
  }
}


class _CheckoutBottomDetailsWidget extends State<CheckoutBottomDetailsWidget> {
  bool _isVisible = false;
  TextEditingController textCont = new TextEditingController();


  void showScheduler() {
    setState(() => _isVisible = !_isVisible);
  }

  @override
  void initState() {
    super.initState();
    textCont = TextEditingController(text: currentCart_note.value);
  }

  @override
  Widget build(BuildContext context) {
    return widget.con.carts.isEmpty
        ? const SizedBox()
        : Container(
            height: 182,
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
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    S.of(context).delivery_fee,
                    style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 13)),
                  ),
                ),
                if (Helper.canDelivery(widget.con.carts[0].food.restaurant,
                    carts: widget.con.carts) &&
                    widget.con.subTotal < setting.value.deliveryFeeLimit)
                  Helper.getPrice(widget.con.carts[0].food.restaurant.deliveryFee, context,
                      style: Theme.of(context).textTheme.subtitle1)
                else
                  Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1)
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Flexible(
                    flex: 1,
                    child: FlatButton(
                          height: 60,
                          onPressed: () => {
                            showDialog(
                              context: context,
                              builder: (context) => getDialog()
                            )
                          },
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                          color: Colors.green,
                          shape: StadiumBorder(),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomEnd,
                            children: <Widget>[
                                Text(
                                  'Promo\nCode',
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                )
                              // Icon(
                              //   Icons.add_sharp,
                              //   color: Theme.of(context).primaryColor,
                              //   size: 28,
                              // ),
                            ],
                          ),
                      )
                ),
                SizedBox(width: 10),
                Flexible(
                  flex: 5,
                  child: Stack(
                      fit: StackFit.loose,
                      alignment: AlignmentDirectional.centerEnd,
                      children: <Widget>[
                        FlatButton(
                              height: 60,
                              onPressed: () => submitOrder(),
                              disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                              color: Colors.green,
                              shape: StadiumBorder(),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  S.of(context).checkout,
                                  style: Theme.of(context).textTheme.bodyText1.merge(
                                      TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
                                ),
                              )
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Helper.getPrice(
                            widget.con.total,
                            context,
                            style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ]
                  )
                )
              ]
            ),
            SizedBox(height: 5),
            Text(
              "Free delivery for orders over Rs. " + setting.value.deliveryFeeLimit.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }



  Widget getDialog() {
    textCont.text = currentCart_note.value;
    return SimpleDialog(
      titlePadding: EdgeInsets.fromLTRB(16, 25, 16, 0),
      title: Row(
        children: <Widget>[
          Icon(
            Icons.account_balance_wallet,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "Enter a valid promo-code:",
              style: Theme.of(context).textTheme.bodyText1,
//                                      textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.fromLTRB(20, 10, 16, 0),
      children: <Widget>[
        TextField(
          keyboardType: TextInputType.multiline,
          controller: textCont,
          maxLength: 10,maxLengthEnforced: true,
          maxLines: 1, // when user presses enter it will adapt to it
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
            MaterialButton(
              onPressed: () {
                currentCart_note.value = textCont.value.text;
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).okay,
                style: TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ],
    );
  }


  void submitOrder() {
    widget.con.onLoadingCartDone();
  }

}

