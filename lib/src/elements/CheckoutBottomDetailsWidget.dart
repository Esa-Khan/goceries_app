import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../src/controllers/checkout_controller.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../elements/PromocodeDialog.dart';

class CheckoutBottomDetailsWidget extends StatelessWidget{
  final CheckoutController con;
  final BuildContext context;

  const CheckoutBottomDetailsWidget ({ Key key, this.con, this.context }): super(key: key);



  @override
  Widget build(BuildContext context) {
    return con.carts.isEmpty
        ? const SizedBox()
        : Wrap (
            children: [
              Container(
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
                          Helper.getPrice(con.subTotal, context,
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
                          if (Helper.canDelivery(con.carts[0].food.restaurant, carts: con.carts) &&
                              con.subTotal < settingsRepo.setting.value.deliveryFeeLimit)
                            Helper.getPrice(con.carts[0].food.restaurant.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                          else
                            Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1)
                        ],
                      ),
                      if (con.promotion != "")
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Promotion Discount',
                                style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 15, color: Theme.of(context).accentColor)),
                              ),
                            ),
                            Text(
                              "Rs.${settingsRepo.setting.value.promo[con.promotion].floor()}",
                              style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Theme.of(context).accentColor, fontSize: 20)),
                            ),
                          ],
                        ),
                      if (con.discount != 0)
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Points Redeemed',
                                style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(fontSize: 15, color: Theme.of(context).accentColor)),
                              ),
                            ),
                            Text(
                              "Rs.${con.discount.toString()}",
                              style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Theme.of(context).accentColor, fontSize: 20)),
                            ),
                          ],
                        ),


                      SizedBox(height: 20),


                      con.order_submitted
                        ? Row (
                            children: [
                              Flexible(
                                child: Stack(
                                    fit: StackFit.loose,
                                    alignment: AlignmentDirectional.centerEnd,
                                    children: <Widget>[
                                      FlatButton(
                                          height: 60,
                                          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: 0),
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
                                          )
                                      ),
                                    ]
                                )
                              )
                            ]
                      )
                      : Row(
                          children: [
                            Flexible(
                                flex: 1,
                                child: FlatButton(
                                  height: 60,
                                  disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                                  onPressed: () => {
                                    con.loading || con.order_submitted
                                        ? null
                                        : PromocodeDialog(
                                            context: context,
                                            con: con
                                          )
                                  },
                                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 2),
                                  color: Theme.of(context).accentColor,
                                  shape: StadiumBorder(),
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    children: <Widget>[
                                      Text(
                                        '+ Promo\nCode',
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
                                          onPressed: () => con.loading || con.order_submitted
                                            ? null
                                            : con.onLoadingCartDone(),
                                          disabledColor: Theme.of(context).focusColor.withOpacity(0.5),
                                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                                          color: Theme.of(context).accentColor,
                                          shape: StadiumBorder(),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              S.of(context).checkout,
                                              style: Theme.of(context).textTheme.bodyText1.merge(
                                                  TextStyle(color: Theme.of(context).primaryColor, fontSize: settingsRepo.compact_view_horizontal ? 15 : 20)),
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        child: Helper.getPrice(
                                          con.total,
                                          context,
                                          style: Theme.of(context).textTheme.headline4.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: settingsRepo.compact_view_horizontal ? 15 : 20)),
                                        ),
                                      ),
                                    ]
                                )
                            )
                          ]
                       ),

                    ],
                  ),
                ),
              )
            ],
    );
  }

}

