import 'package:flutter/material.dart';
import '../../src/models/route_argument.dart';

import '../helpers/custom_trace.dart';
import '../models/payment_method.dart';
import '../pages/checkout.dart';
import 'ConfirmationDialogBox.dart';

// ignore: must_be_immutable
class PaymentMethodListItemWidget extends StatelessWidget {
  String heroTag;
  PaymentMethod paymentMethod;

  PaymentMethodListItemWidget({Key key, this.paymentMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        if (this.paymentMethod.id == "mastercard" || this.paymentMethod.id == "visacard") {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutWidget(
                  cardType: this.paymentMethod.id,
                ),
              ));
        } else if(this.paymentMethod.id == "paypal"){
          Navigator.of(context).pushNamed(this.paymentMethod.route);
        } else {
          Navigator.of(context).pushNamed(this.paymentMethod.route, arguments: new RouteArgument(param: 'Cash on Delivery'));
        }
        print(CustomTrace(StackTrace.current, message: this.paymentMethod.name));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(image: AssetImage(paymentMethod.logo), fit: BoxFit.fill),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          paymentMethod.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          paymentMethod.description,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).focusColor,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
