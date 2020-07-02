import 'dart:math';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/CartBottomDetailsWidget.dart';

import '../../generated/l10n.dart';
import '../models/credit_card.dart';

// ignore: must_be_immutable
class PaymentSettingsDialog extends StatefulWidget {
  CreditCard creditCard;
  VoidCallback onChanged;

  PaymentSettingsDialog({Key key, this.creditCard, this.onChanged}) : super(key: key);

  @override
  _PaymentSettingsDialogState createState() => _PaymentSettingsDialogState();
}

class _PaymentSettingsDialogState extends State<PaymentSettingsDialog> {
  GlobalKey<FormState> _paymentSettingsFormKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    super.dispose();
  }

  String validateEXP(String input) {
    DateTime currDate = DateTime.now();
    int inputMonth = int.tryParse(input.substring(0, 2));
    int inputYear = int.tryParse(input.substring(3, 5));

    if (!input.contains('/') || input.length != 5) {
      return S.of(context).not_a_valid_date;
    } else if(inputMonth > 12 || inputMonth < 1) {
      return "Invalid: Month has to be 1 - 12";
    } else if(inputYear < int.tryParse(currDate.year.toString().substring(2, 4))) {
      return "Invalid: Date can't be in the past";
    } else if(inputYear == int.tryParse(currDate.year.toString().substring(2, 4)) && inputMonth < currDate.month) {
      return "Invalid: Date can't be in the past";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                titlePadding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                title: Row(
                  children: <Widget>[
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text(
                      S.of(context).payment_settings,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
                children: <Widget>[
                  Form(
                    key: _paymentSettingsFormKey,
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                          decoration: getInputDecoration(hintText: '4242 4242 4242 4242', labelText: S.of(context).number),
                          initialValue: widget.creditCard.number.isNotEmpty ? widget.creditCard.number : null,
                          validator: (input) => input.trim().length != 16 ? S.of(context).not_a_valid_number : null,
                          onSaved: (input) => widget.creditCard.number = input,
                        ),
                        new TextFormField(
                            style: TextStyle(color: Theme.of(context).hintColor),
//                            controller: expTextCon,
                            keyboardType: TextInputType.datetime,
                            decoration: getInputDecoration(hintText: 'mm/yy', labelText: S.of(context).exp_date),
                            initialValue: widget.creditCard.expMonth.isNotEmpty ? widget.creditCard.expMonth + '/' + widget.creditCard.expYear : null,
                            validator: (input) => validateEXP(input),
                            onSaved: (input) {
                              widget.creditCard.expMonth = input.split('/').elementAt(0);
                              widget.creditCard.expYear = input.split('/').elementAt(1);
                            }),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.number,
                          decoration: getInputDecoration(hintText: '253', labelText: S.of(context).cvc),
                          initialValue: widget.creditCard.cvc.isNotEmpty ? widget.creditCard.cvc : null,
                          validator: (input) => input.trim().length != 3 ? S.of(context).not_a_valid_cvc : null,
                          onSaved: (input) => widget.creditCard.cvc = input,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).cancel),
                      ),
                      MaterialButton(
                        onPressed: _submit,
                        child: Text(
                          S.of(context).save,
                          style: TextStyle(color: Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                  SizedBox(height: 10),
                ],
              );
            });
      },
      child: Text(
        S.of(context).edit,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText2.merge(
            TextStyle(color: Theme.of(context).focusColor),
          ),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText2.merge(
            TextStyle(color: Theme.of(context).hintColor),
          ),
    );
  }

  void _submit() {
    if (_paymentSettingsFormKey.currentState.validate()) {
      _paymentSettingsFormKey.currentState.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
