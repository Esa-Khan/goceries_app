import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../../src/controllers/delivery_pickup_controller.dart';
import '../../src/repository/cart_repository.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';
import '../../src/repository/settings_repository.dart';
import 'OrderNotesWidget.dart';


class CartBottomDetailsWidget extends StatefulWidget{
  final CartController con;

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


class _CartBottomDetailsWidget extends State<CartBottomDetailsWidget> {
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
        ? SizedBox(height: 0)
        : Container(
            height: 180,
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
                    blurRadius: 5.0
                )
              ]
            ),
      child: SizedBox(
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
                    child: Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: <Widget>[
                        FlatButton(
                            height: 60,
                            onPressed: () => {
                              showDialog(
                                  context: context,
                                  builder: (context) => getDialog()
                              )
                            },
                            disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                            color: !widget.con.carts[0].food.restaurant.closed
                                ? Theme.of(context).accentColor
                                : Theme.of(context).focusColor.withOpacity(0.5),
                            shape: StadiumBorder(),
                            child: Text(
                                  'Extra\nNotes',
                                  textAlign: TextAlign.center,
                                  textScaleFactor: 0.7,
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                )),
                                if (currentCart_note.value.trim().length != 0)
                                  Positioned(
                                    top: 0,
                                    child: Container(
                                      child: Icon(Icons.check, size: 20, color: Theme.of(context).primaryColor),
                                      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    ),
                                  )
                      ],
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
                              onPressed: widget.con.item_unavail ? null : () => widget.con.goCheckout(context),
                              disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                              color: !widget.con.carts[0].food.restaurant.closed
                                  ? Theme.of(context).accentColor
                                  : Theme.of(context).focusColor.withOpacity(0.5),
                              shape: StadiumBorder(),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: widget.con.item_unavail
                                  ? Text(
                                      'Item(s) out of stock',
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyText1.merge(
                                      TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
                                    )
                                  : Text(
                                      'Next',
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

              // "Free delivery for orders over Rs. " + setting.value.deliveryFeeLimit.toString(),
              widget.con.subTotal < setting.value.deliveryFeeLimit
                ? RichText(
                    text: TextSpan(
                      text: 'Order ',
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(text: 'Rs.' + (setting.value.deliveryFeeLimit - widget.con.subTotal).toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent[400])),
                        TextSpan(text: ' more to get free delivery.'),
                      ],
                    ),
                  )
                : Text(
                  'Eligible for free delivery',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 13, color: Colors.greenAccent[400], fontWeight: FontWeight.bold)),
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
            Icons.speaker_notes,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "If you need a specific item or want to let our team know something about this order:",
              style: Theme.of(context).textTheme.bodyText1,
//                                      textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              maxLines: 5,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.fromLTRB(20, 10, 16, 0),
      children: <Widget>[
        TextField(
          keyboardType: TextInputType.multiline,
          controller: textCont,
          minLines: 1,
          //Normal textInputField will be displayed
          maxLines: 20, // when user presses enter it will adapt to it
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
                setState(() => currentCart_note.value = textCont.value.text);
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

}

