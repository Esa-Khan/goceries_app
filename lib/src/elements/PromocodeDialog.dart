import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saudaghar/src/repository/settings_repository.dart' as settingsRepo;
import 'package:saudaghar/src/repository/user_repository.dart';

import '../../generated/l10n.dart';
import '../helpers/checkbox_form_field.dart';
import '../models/address.dart';
import '../controllers/user_controller.dart';

// ignore: must_be_immutable
class PromocodeDialog {
  BuildContext context;
  ValueChanged<double> onChanged;
  GlobalKey<FormState> form_key = new GlobalKey<FormState>();
  TextEditingController phoneTextCon = new TextEditingController(text: currentUser.value.phone);

  PromocodeDialog({this.context, this.onChanged}) {
    phoneTextCon.text = currentUser.value.phone;

    String valdiatePromocode(String input){
      if(settingsRepo.setting.value.promo.containsKey(input)){
        return null;

      } else {
        return "Invalid code";
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
//            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            titlePadding: EdgeInsets.fromLTRB(16, 25, 16, 0),
            title: Row(
              children: <Widget>[
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).hintColor,
                ),
                SizedBox(width: 15),
                Text(
                  "Enter a valid promo-code:",
//                  S.of(context).add_delivery_address,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
            children: <Widget>[
              Form(
                key: form_key,
                child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: new TextFormField(
                        style: TextStyle(color: Theme.of(context).hintColor),
                        decoration: getInputDecoration(labelText: 'Code'),
                        validator: (input) => valdiatePromocode(input),
//                        onSaved: (input) => currentUser.value.phone = input,
                      ),
                    ),
              ),
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
    if (form_key.currentState.validate()) {
      onChanged(100);
      Navigator.of(context).pop();
    }
  }


}
