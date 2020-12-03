import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../src/controllers/settings_controller.dart';
import '../../src/repository/user_repository.dart';

import '../../generated/l10n.dart';
import '../helpers/checkbox_form_field.dart';
import '../models/address.dart';
import '../controllers/user_controller.dart';

// ignore: must_be_immutable
class DeliveryAddressDialog {
  BuildContext context;
  Address address;
  String phone;
  ValueChanged<Address> onChanged;
  GlobalKey<FormState> _deliveryAddressFormKey = new GlobalKey<FormState>();
  TextEditingController phoneTextCon = new TextEditingController(text: currentUser.value.phone);

  DeliveryAddressDialog({this.context, this.address, this.onChanged}) {
    phoneTextCon.text = currentUser.value.phone;

    String validatePhone(String input){
      if (input.length == 0) {
        return "Invalid: Cannot leave empty";

      } else if (input.length < 11){
        return "Invalid: Number must be 11 digits";

      } else if (input.substring(0, 2) != '03'){
        return "Invalid: Number must start with '03'";

      } else if(int.tryParse(input) == null){
        return "Invalid: Only numbers allowed";

      } else {
        return null;
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
                  Icons.place,
                  color: Theme.of(context).hintColor,
                ),
                SizedBox(width: 10),
                Text(
                  "Confirm address and number",
//                  S.of(context).add_delivery_address,
                  style: Theme.of(context).textTheme.bodyText1,
                )
              ],
            ),
            children: <Widget>[
              Form(
                key: _deliveryAddressFormKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: new TextFormField(
                        style: TextStyle(color: Theme.of(context).hintColor),
                        keyboardType: TextInputType.text,
                        decoration: getInputDecoration(hintText: S.of(context).hint_full_address, labelText: S.of(context).full_address),
                        initialValue: address.address?.isNotEmpty ?? false ? address.address : null,
                        validator: (input) => input.trim().length == 0 ? 'Not valid address' : null,
                        onSaved: (input) => address.address = input,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: new TextFormField(
                        style: TextStyle(color: Theme.of(context).hintColor),
                        keyboardType: TextInputType.numberWithOptions(decimal: false, signed: false),
                        controller: phoneTextCon,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          new LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: getInputDecoration(hintText: "03001234567", labelText: S.of(context).phone_number),
                        // initialValue: currentUser.value.phone,
                        validator: (input) => validatePhone(input),
//                        onSaved: (input) => currentUser.value.phone = input,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: CheckboxFormField(
                        context: context,
                        initialValue: address.isDefault ?? false,
                        onSaved: (input) => address.isDefault = input,
                        title: Text('Make it default'),
                      ),
                    )
                  ],
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
    if (_deliveryAddressFormKey.currentState.validate()) {
      _deliveryAddressFormKey.currentState.save();
      onChanged(address);
      currentUser.value.phone = phoneTextCon.value.text;
      update(currentUser.value);
      Navigator.pop(context);
    }
  }


}
