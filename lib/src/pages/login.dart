import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart' as userRepo;
import '../repository/settings_repository.dart' as _setting;

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  UserController _con;
  _LoginWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.apiToken != null) {
      Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Container(
            width: config.App(context).appWidth(100),
            height: config.App(context).appHeight(29.5),
            decoration: BoxDecoration(color: Theme.of(context).accentColor),
          ),
          ListView(
            shrinkWrap: true,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: _setting.compact_view_vertical ? 10 : 45, bottom: 10),
                  child: Column(
                      children: [
                        Container(
                          width: config.App(context).appWidth(84),
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            S.of(context).lets_start_with_login,
                            style: Theme.of(context).textTheme.headline2.merge(
                                TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
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
                          child: Form(
                            key: _con.loginFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _con.supportsAppleSignIn
                                  ? SignInButton(
                                    _setting.setting.value.brightness.value == Brightness.light
                                      ? Buttons.AppleDark
                                      : Buttons.Apple,
                                      elevation: 10,
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      onPressed: () {
                                      _con.signInWithApple();
                                      },
                                    )
                                  : const SizedBox(),
                                _con.supportsAppleSignIn
                                  ? const Divider(height: 10)
                                  : const SizedBox(),
                                SignInButton(
                                  _setting.setting.value.brightness.value == Brightness.light
                                      ? Buttons.Google
                                      : Buttons.GoogleDark,
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  elevation: 10,
                                  onPressed: () {
                                    _con.signInWithGoogle();
                                  },
                                ),
                                const Divider(height: 10),
                                SignInButton(
                                  Buttons.Facebook,
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  elevation: 10,
                                  onPressed: () {
                                    _con.signInWithFacebook();
                                  },
                                ),


                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: _setting.compact_view_vertical ? 5 : 15),
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
                                const SizedBox(height: 20),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: S.of(context).dont_have_an_account,
                                      style: Theme.of(context).textTheme.bodyText1,
                                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).popAndPushNamed('/SignUp')),
                                ),
                                const SizedBox(height: 10),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: S.of(context).forgot_password,
                                      style: Theme.of(context).textTheme.bodyText1,
                                      recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).pushNamed('/ForgetPassword')),
                                ),

                                // FlatButton(
                                //   onPressed: () {
                                //     Navigator.of(context).pushNamed('/SignUp');
                                //   },
                                //   textColor: Theme.of(context).hintColor,
                                //   child: Text(S.of(context).dont_have_an_account, textAlign: TextAlign.center),
                                // ),
                                // FlatButton(
                                //   onPressed: () {
                                //     Navigator.of(context).pushNamed('/ForgetPassword');
                                //   },
                                //   textColor: Theme.of(context).hintColor,
                                //   child: Text(S.of(context).forgot_password, textAlign: TextAlign.center),
                                // )
                              ],
                            ),
                          ),
                        )
                      ])),
                      FlatButton(
                        onPressed: () {
                          // Navigator.of(context).pushReplacementNamed('/StoreSelect');
                          Navigator.pop(context);
                        },
                        shape: StadiumBorder(),
                        textColor: Theme.of(context).hintColor,
                        child: Text(S.of(context).skip)
                      ),
              const SizedBox(height: 50)
            ]
          ),
        ],
      ),
    );
  }
}
