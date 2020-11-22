import 'dart:io';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:flutter/material.dart';
import '../elements/FacebookSigninButtonWidget.dart';
import '../elements/GoogleSigninButtonWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart' as userRepo;
import '../helpers/helper.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  UserController _con;
  bool supportsAppleSignIn = false;
  _LoginWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    Helper.checkiOSVersion().then((value) => setState(() => supportsAppleSignIn = value));
    if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Container(
            width: config.App(context).appWidth(100),
            height: config.App(context).appHeight(30),
            decoration: BoxDecoration(color: Theme.of(context).accentColor),
          ),
          Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                      children: [
                        Container(
                          width: config.App(context).appWidth(84),
                          child: Text(
                            S.of(context).lets_start_with_login,
                            style: Theme.of(context).textTheme.headline2.merge(
                                TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 50,
                                  color: Theme.of(context).hintColor.withOpacity(0.2),
                                )
                              ]),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.only(top: 20, right: 27, left: 27, bottom: 20),
                          width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                          child: Form(
                            key: _con.loginFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FacebookSigninButtonWidget(con: _con),
                                const Divider(height: 15),
                                GoogleSigninButtonWidget(con: _con),
                                const Divider(height: 15),
                                supportsAppleSignIn
                                  ? Container(
                                      // height: screenHeight / 15,
                                      // width: screenWidth / 1.5,
                                      child: AppleSignInButton(
                                        // style: ButtonStyle.black,
                                        type: ButtonType.continueButton,
                                        onPressed: () {
                                          _con.signInWithApple();
                                        },
                                      ),
                                    )
                                  : const SizedBox(height: 0),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Text(
                                      "OR",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .button
                                          .apply(color: Theme.of(context).accentColor),
                                    )),
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (input) => _con.user.email = input,
                                  validator: (input) => !input.contains('@')
                                      ? S.of(context).should_be_a_valid_email
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: S.of(context).email,
                                    labelStyle:
                                    TextStyle(color: Theme.of(context).accentColor),
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: 'johndoe@gmail.com',
                                    hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.7)),
                                    prefixIcon: Icon(Icons.alternate_email,
                                        color: Theme.of(context).accentColor),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.2))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.5))),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.2))),
                                  ),
                                ),
                                const Divider(height: 15),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  onSaved: (input) => _con.user.password = input,
                                  validator: (input) => input.length < 3
                                      ? S.of(context).should_be_more_than_3_characters
                                      : null,
                                  obscureText: _con.hidePassword,
                                  decoration: InputDecoration(
                                    labelText: S.of(context).password,
                                    labelStyle:
                                    TextStyle(color: Theme.of(context).accentColor),
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: '••••••••••••',
                                    hintStyle: TextStyle(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.7)),
                                    prefixIcon: Icon(Icons.lock_outline,
                                        color: Theme.of(context).accentColor),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _con.hidePassword = !_con.hidePassword;
                                        });
                                      },
                                      color: Theme.of(context).focusColor,
                                      icon: Icon(_con.hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                    ),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.2))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.5))),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.2))),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                BlockButtonWidget(
                                  text: Text(
                                    S.of(context).login,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () {
                                    _con.login();
                                  },
                                ),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed('/StoreSelect');
                                  },
                                  shape: StadiumBorder(),
                                  textColor: Theme.of(context).hintColor,
                                  child: Text(S.of(context).skip),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 19),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: FlatButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushReplacementNamed('/ForgetPassword');
                                        },
                                        textColor: Theme.of(context).hintColor,
                                        child: Text(S.of(context).forgot_password, textAlign: TextAlign.center),
                                      )
                                    ),
                                    Expanded(
                                        child: FlatButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushReplacementNamed('/SignUp');
                                          },
                                          textColor: Theme.of(context).hintColor,
                                          child: Text(S.of(context).dont_have_an_account, textAlign: TextAlign.center),
                                        )
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      ])),
            ]
          )),
        ],
      ),
    );
  }
}
