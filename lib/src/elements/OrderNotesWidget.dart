import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';

import '../../generated/l10n.dart';
import '../helpers/checkbox_form_field.dart';
import '../models/address.dart';

// ignore: must_be_immutable
class OrderNotesWidget {
  BuildContext context;
  GlobalKey<FormState> _deliveryAddressFormKey = new GlobalKey<FormState>();

  OrderNotesWidget({this.context}) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
//            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            titlePadding: EdgeInsets.fromLTRB(16, 25, 16, 0),
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.speaker_notes,
                  color: Theme.of(context).hintColor,
                ),
                Text(
                  "Any special notes?",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            contentPadding: EdgeInsets.fromLTRB(20, 10, 16, 0),
            children: <Widget>[
              Text(
                    "Do you have any special instructions related to this order?",
                style: Theme.of(context).textTheme.bodyText2,
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
                    onPressed: _submit,
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
        });
  }

  void _submit() {
//    if (route == '/CashOnDelivery') {
//      Navigator.of(context).pushNamed(route, arguments: new RouteArgument(id: hint, param: 'Cash on Delivery'));
//    } else {
//      Navigator.pop(context);
//    }
  print("-----SUBMITTED-----");
  }
}
