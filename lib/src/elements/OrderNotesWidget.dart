import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saudaghar/src/models/route_argument.dart';

import '../../generated/l10n.dart';
import '../helpers/checkbox_form_field.dart';
import '../models/address.dart';

// ignore: must_be_immutable
class OrderNotesWidget {
  final con;
  TextEditingController textCont = new TextEditingController();
  BuildContext context;
  GlobalKey<FormState> _deliveryAddressFormKey = new GlobalKey<FormState>();


  OrderNotesWidget({this.context, this.con}) {
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
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    con.hint == null
                        ? "Have special instructions for this order?"
                        : con.hint,
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.left,
//                    overflow: TextOverflow.fade,
//                    maxLines: 5,
                  ),
                ),
              ],
            ),
            contentPadding: EdgeInsets.fromLTRB(20, 10, 16, 0),
            children: <Widget>[
              TextField(
              keyboardType: TextInputType.multiline,
                controller: textCont,
                minLines: 1,//Normal textInputField will be displayed
                maxLines: 5,// when user presses enter it will adapt to it
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
    con.hint = textCont.value.text;
    Navigator.pop(context);
  }
}
