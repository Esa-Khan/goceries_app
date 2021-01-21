import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/settings_repository.dart' as _setting;

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  UserController _con;
  final textEditingContoller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textEditingContoller.dispose();
    super.dispose();
  }


  _SignUpWidgetState() : super(UserController()) {
    _con = controller;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: true,
          body: Stack(alignment: AlignmentDirectional.topCenter, children: <
                Widget>[
              Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(29.5),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 45),
                    child: Column(
                      children: [
                        Container(
                          width: config.App(context).appWidth(84),
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            S.of(context).register_a_new_account,
                            style: Theme.of(context).textTheme.headline2.merge(TextStyle(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                          Container(
                            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                              BoxShadow(
                                blurRadius: 50,
                                color: Theme.of(context).hintColor.withOpacity(0.2),
                              )
                            ]),
                            margin: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 27),
                            width: config.App(context).appWidth(88),
            //              height: config.App(context).appHeight(55),
                            child: Form(
                              key: _con.loginFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // FacebookSigninButtonWidget(con: _con, isLogin: false),
                                  // const Divider(height: 15),
                                  // GoogleSigninButtonWidget(con: _con, isLogin: false),
                                  // const Divider(height: 15),
                                  // _con.supportsAppleSignIn
                                  //     ? AppleSigninButtonWidget(con: _con, isLogin: false)
                                  //     : const SizedBox(),
                                  _con.supportsAppleSignIn
                                      ? SignInButton(
                                          _setting.setting.value.brightness.value == Brightness.light
                                              ? Buttons.AppleDark
                                              : Buttons.Apple,
                                          text: "Sign up with Apple",
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
                                    elevation: 10,
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    text: "Sign up with Google",
                                    onPressed: () {
                                      _con.signInWithGoogle();
                                    },
                                  ),
                                  const Divider(height: 10),
                                  SignInButton(
                                    Buttons.Facebook,
                                    text: "Sign up with Facebook",
                                    elevation: 10,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    onPressed: () {
                                      _con.signInWithFacebook();
                                    },
                                  ),
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
                                    keyboardType: TextInputType.text,
                                    onSaved: (input) => _con.user.name = input,
                                    validator: (input) => input.length < 3 ? S.of(context).should_be_more_than_3_letters : null,
                                    decoration: InputDecoration(
                                      labelText: S.of(context).full_name,
                                      labelStyle: TextStyle(color: Theme.of(context).accentColor),
                                      contentPadding: EdgeInsets.all(12),
                                      hintText: S.of(context).john_doe,
                                      hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                                      prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).accentColor),
                                      border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (input) => _con.user.email = input,
                                    validator: (input) => !input.contains('@') ? S.of(context).should_be_a_valid_email : null,
                                    decoration: InputDecoration(
                                      labelText: S.of(context).valid_email,
                                      labelStyle: TextStyle(color: Theme.of(context).accentColor),
                                      contentPadding: EdgeInsets.all(12),
                                      hintText: 'johndoe@gmail.com',
                                      hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                                      prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).accentColor),
                                      border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  TextFormField(
                                    obscureText: _con.hidePassword,
                                    onSaved: (input) => _con.user.password = input,
                                    validator: (input) => input.length < 6 ? S.of(context).should_be_more_than_6_letters : null,
                                    controller: textEditingContoller,
                                    decoration: InputDecoration(
                                      labelText: S.of(context).password,
                                      labelStyle: TextStyle(color: Theme.of(context).accentColor),
                                      contentPadding: EdgeInsets.all(12),
                                      hintText: '••••••••••••',
                                      hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                                      prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).accentColor),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() => _con.hidePassword = !_con.hidePassword);
                                        },
                                        color: Theme.of(context).focusColor,
                                        icon: Icon(_con.hidePassword ? Icons.visibility_off : Icons.visibility),
                                      ),
                                      border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  TextFormField(
                                    obscureText: _con.hidePassword,
                                    onSaved: (input) => _con.user.confirm_password = input,
                                    validator: (input) {
                                      if (input.length < 3) {
                                        return S.of(context).should_be_more_than_3_letters;
                                      } else if (input != textEditingContoller.text) {
                                        return S.of(context).passwords_dont_match;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      labelText: S.of(context).confirm_password,
                                      labelStyle: TextStyle(color: Theme.of(context).accentColor),
                                      contentPadding: EdgeInsets.all(12),
                                      hintText: '••••••••••••',
                                      hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                                      prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).accentColor),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() => _con.hidePassword = !_con.hidePassword);
                                        },
                                        color: Theme.of(context).focusColor,
                                        icon: Icon(_con.hidePassword ? Icons.visibility_off : Icons.visibility),
                                      ),
                                      border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  BlockButtonWidget(
                                    text: Text(
                                      S.of(context).register,
                                      style: TextStyle(color: Theme.of(context).primaryColor),
                                    ),
                                    color: Theme.of(context).accentColor,
                                    onPressed: () {
                                      _con.register();
                                    },
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).popAndPushNamed('/Login');
                                    },
                                    textColor: Theme.of(context).hintColor,
                                    child: Text(S.of(context).i_have_account_back_to_login,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context).textTheme.bodyText1,
                                            ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 19),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        FlatButton(
                          onPressed: () {
                            // Navigator.of(context).pushReplacementNamed('/StoreSelect');
                            Navigator.pop(context);
                          },
                          shape: StadiumBorder(),
                          textColor: Theme.of(context).hintColor,
                          child: Text(S.of(context).skip),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 19),
                        )
                ]))
          ])
        ]));
  }
}
