import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';

// ignore: must_be_immutable
class DeliveryAddressesItemWidget extends StatelessWidget {
  String heroTag;
  model.Address address;
  PaymentMethod paymentMethod;
  ValueChanged<model.Address> onPressed;
  ValueChanged<model.Address> onLongPress;
  ValueChanged<model.Address> onDismissed;

  DeliveryAddressesItemWidget({Key key, this.address, this.onPressed, this.onLongPress, this.onDismissed, this.paymentMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onDismissed != null) {
      return Dismissible(
        key: Key(address.id),
        onDismissed: (direction) {
          this.onDismissed(address);
        },
        child: buildItem(context),
      );
    } else {
      return buildItem(context);
    }
  }


  IconData getIcon() {
    if (paymentMethod == null || (paymentMethod.selected && paymentMethod.addressID == address.id)){
      return Icons.check;
    } else if (address == null){
      return Icons.error;
    } else {
      return Icons.local_shipping;
    }
  }

  InkWell buildItem(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        this.onPressed(address);
      },
      onLongPress: () {
        if (address != null)
          this.onLongPress(address);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
//                      color: (address?.isDefault ?? false) || paymentMethod.selected ? Theme.of(context).accentColor : Theme.of(context).focusColor),
                      color: (address?.isDefault ?? false) ? Theme.of(context).accentColor
                          : address != null ? Theme.of(context).focusColor : Colors.redAccent),
                  child: Icon(
//                    paymentMethod == null || (paymentMethod.selected && paymentMethod.addressID == address.id) ? Icons.check : Icons.local_shipping,
                    getIcon(),
                    color: Theme.of(context).primaryColor,
                    size: 38,
                  ),
                ),
              ],
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
                        address?.description != null
                            ? Text(
                                address.description,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.subtitle1,
                              )
                            : SizedBox(height: 0),
                        Text(
                          address?.address ?? S.of(context).choose_an_address,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: address?.description != null ? Theme.of(context).textTheme.caption : Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
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
