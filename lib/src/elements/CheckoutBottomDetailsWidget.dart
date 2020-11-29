import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:saudaghar/src/controllers/checkout_controller.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../elements/PromocodeDialog.dart';

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
  CheckoutController _con;



  @override
  void initState() {
    super.initState();
    _con = widget.con;
  }

  @override
  Widget build(BuildContext context) {
    return _con.carts.isEmpty
        ? const SizedBox()
        : Container(
            height: _con.promotion == '' ? 182 : 200,
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
                Helper.getPrice(_con.subTotal, context,
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
                if (Helper.canDelivery(_con.carts[0].food.restaurant,
                    carts: _con.carts) &&
                    _con.subTotal < settingsRepo.setting.value.deliveryFeeLimit)
                  Helper.getPrice(_con.carts[0].food.restaurant.deliveryFee, context,
                      style: Theme.of(context).textTheme.subtitle1)
                else
                  Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1)
              ],
            ),
            _con.promotion == ""
              ? const SizedBox()
              : Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Promotion Discount',
                    style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 13, color: Colors.greenAccent)),
                  ),
                ),
                RichText(
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  text: TextSpan(
                          text: settingsRepo.setting.value.promo[_con.promotion].toString(),
                          style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Colors.greenAccent)),
                        ),
                )
              ],
            ),
            SizedBox(height: 20),
            _con.order_submitted
              ? Row(
                  children: [
                    Flexible(
                      child: Stack(
                          fit: StackFit.loose,
                          alignment: AlignmentDirectional.centerEnd,
                          children: <Widget>[
                            FlatButton(
                                height: 60,
                                onPressed: () => gotoOrders(),
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                                color: Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Align(
                                  child: Text(
                                    'Track Order',
                                    style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontSize: 20)),
                                  ),
                                )),
                          ]))
                        ])




                      : Row(
                          children: [
                            Flexible(
                                flex: 1,
                                child: FlatButton(
                                  height: 60,
                                  disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                                  onPressed: () => {
                                    _con.loading || _con.order_submitted
                                        ? null
                                        : PromocodeDialog(
                                            context: this.context,
                                            con: _con
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
                                          onPressed: () => _con.loading || _con.order_submitted
                                              ? null
                                              : submitOrder(),
                                          disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                                          color: Colors.green,
                                          shape: StadiumBorder(),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              S.of(context).checkout,
                                              style: Theme.of(context).textTheme.bodyText1.merge(
                                                  TextStyle(color: Theme.of(context).primaryColor, fontSize: settingsRepo.compact_view ? 15 : 20)),
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Helper.getPrice(
                                          _con.total,
                                          context,
                                          style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: settingsRepo.compact_view ? 15 : 20)),
                                        ),
                                      ),
                                    ]
                                )
                            )
                          ]
            ),

            SizedBox(height: 5),
            Text(
              "Free delivery for orders over Rs. " + settingsRepo.setting.value.deliveryFeeLimit.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }




  void submitOrder() {
    _con.onLoadingCartDone();
  }

  void gotoOrders() {
    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 3);
  }

}

