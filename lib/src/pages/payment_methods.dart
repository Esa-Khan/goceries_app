import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../elements/PaymentMethodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class PaymentMethodsWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  PaymentMethodsWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _PaymentMethodsWidgetState createState() => _PaymentMethodsWidgetState(routeArgument);
}

class _PaymentMethodsWidgetState extends State<PaymentMethodsWidget> {
  PaymentMethodList list;
  RouteArgument routeArgument;

  _PaymentMethodsWidgetState(this.routeArgument) : super() {
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    list = new PaymentMethodList(context);
    if (!setting.value.payPalEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "paypal";
      });
    if (!setting.value.razorPayEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "razorpay";
      });
    if (!setting.value.stripeEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "visacard" || element.id == "mastercard";
      });
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.transparent,
        // elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).payment_mode,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            list.paymentsList.length > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                    child: ListTile(
                      leading: Icon(
                        Icons.payment,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).select_your_preferred_payment_mode,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  )
                : const SizedBox(),
            SizedBox(height: 10),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: list.paymentsList.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return PaymentMethodListItemWidget(paymentMethod: list.paymentsList.elementAt(index));
              },
            ),
//            list.cashList.length > 0
//                ? Padding(
//                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                    child: ListTile(
//                      contentPadding: EdgeInsets.symmetric(vertical: 0),
//                      leading: Icon(
//                        Icons.monetization_on,
//                        color: Theme.of(context).hintColor,
//                      ),
//                      title: Text(
//                        S.of(context).cash_on_delivery,
//                        maxLines: 1,
//                        overflow: TextOverflow.ellipsis,
//                        style: Theme.of(context).textTheme.headline4,
//                      ),
//                      subtitle: Text(S.of(context).select_your_preferred_payment_mode),
//                    ),
//                  )
//                : SizedBox(
//                    height: 0,
//                  ),
          SizedBox(height: 10),
          ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            itemCount: list.cashList.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            itemBuilder: (context, index) {
              return PaymentMethodListItemWidget(paymentMethod: list.cashList.elementAt(index));
            },
          ),
          ],
        ),
      ),
    );
  }
}
