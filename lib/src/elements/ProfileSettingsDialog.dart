import 'package:flutter/material.dart';
import '../../src/repository/user_repository.dart';

import '../../generated/l10n.dart';
import '../models/user.dart';

class ProfileSettingsDialog extends StatefulWidget {
  final User user;
  final VoidCallback onChanged;

  ProfileSettingsDialog({Key key, this.user, this.onChanged}) : super(key: key);

  @override
  _ProfileSettingsDialogState createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();

  String validatePhone(String input){
    if (input.trim().length == 0){
      return "Phone number needed";

    } else if(int.tryParse(input) == null){
      return "Only numbers allowed";

    } else if(input.trim().length != 11){
      return "Needs to be 11 digits";

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
                    const SizedBox(width: 10),
                    Text(
                      S.of(context).profile_settings,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
                children: <Widget>[
                  Form(
                    key: _profileSettingsFormKey,
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(hintText: S.of(context).john_doe, labelText: S.of(context).full_name),
                          initialValue: widget.user.name,
                          validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_full_name : null,
                          onSaved: (input) => widget.user.name = input,
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: getInputDecoration(hintText: 'johndo@gmail.com', labelText: S.of(context).email_address),
                          initialValue: widget.user.email,
                          validator: (input) => !input.contains('@') ? S.of(context).not_a_valid_email : null,
                          onSaved: (input) => widget.user.email = input,
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(hintText: '03001234567', labelText: S.of(context).phone),
                          initialValue: widget.user.phone,
                          validator: (input) => validatePhone(input),
                          onSaved: (input) => widget.user.phone = input,
                        ),
//                        new TextFormField(
//                          style: TextStyle(color: Theme.of(context).hintColor),
//                          keyboardType: TextInputType.text,
//                          decoration: getInputDecoration(hintText: S.of(context).your_address, labelText: S.of(context).address),
//                          initialValue: currentUser.value.address,
//                          validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_address : null,
//                          onSaved: (input) => widget.user.address = input,
//                        ),
//                        new TextFormField(
//                          style: TextStyle(color: Theme.of(context).hintColor),
//                          keyboardType: TextInputType.text,
//                          decoration: getInputDecoration(hintText: S.of(context).your_biography, labelText: S.of(context).about),
//                          initialValue: widget.user.bio,
//                          validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_biography : null,
//                          onSaved: (input) => widget.user.bio = input,
//                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 10),
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
    if (_profileSettingsFormKey.currentState.validate()) {
      _profileSettingsFormKey.currentState.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
