import 'dart:io';

import 'package:flutter/material.dart';
import 'package:saudaghar/src/elements/FacebookSigninButtonWidget.dart';
import 'package:saudaghar/src/elements/GoogleSigninButtonWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../repository/user_repository.dart' as userRepo;

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
          Positioned(
            top: 0,
            child: Container(
              width: config.App(context).appWidth(100),
              height: config.App(context).appHeight(30),
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
            ),
          ),
          Positioned(
            top: config.App(context).appHeight(37) - 180,
            child: Container(
              width: config.App(context).appWidth(84),
              height: config.App(context).appHeight(37),
              child: Text(
                S.of(context).lets_start_with_login,
                style: Theme.of(context).textTheme.headline2.merge(TextStyle(color: Theme.of(context).primaryColor)),
              ),
            ),
          ),
          Positioned(
            top: config.App(context).appHeight(37) - 150,
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.all(Radius.circular(10)), boxShadow: [
                BoxShadow(
                  blurRadius: 50,
                  color: Theme.of(context).hintColor.withOpacity(0.2),
                )
              ]),
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              padding: EdgeInsets.only(top: 10, right: 27, left: 27, bottom: 20),
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


                    SignInWithAppleButton(
                      onPressed: () async {
                        final credential = await SignInWithApple.getAppleIDCredential(
                          scopes: [
                            AppleIDAuthorizationScopes.email,
                            AppleIDAuthorizationScopes.fullName,
                          ],
                          webAuthenticationOptions: WebAuthenticationOptions(
                            clientId: 'com.ezpz.saudagharservice',
                            redirectUri: Uri.parse(
                              'https://mint-pumped-viscose.glitch.me/callbacks/sign_in_with_apple',
                            ),
                          ),
                        );

                        print(credential);

                        // This is the endpoint that will convert an authorization code obtained
                        // via Sign in with Apple into a session in your system
                        final signInWithAppleEndpoint = Uri(
                          scheme: 'https',
                          host: 'mint-pumped-viscose.glitch.me',
                          path: '/sign_in_with_apple',
                          queryParameters: <String, String>{
                            'code': credential.authorizationCode,
                            'firstName': credential.givenName,
                            'lastName': credential.familyName,
                            'useBundleId':
                            Platform.isIOS || Platform.isMacOS ? 'true' : 'false',
                            if (credential.state != null) 'state': credential.state,
                          },
                        );

                        final session = await http.Client().post(
                          signInWithAppleEndpoint,
                        );

                        // If we got this far, a session based on the Apple ID credential has been created in your system,
                        // and you can now set this as the app's session
                        print(session);
                      },
                    ),


                    Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text("OR",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).accentColor),
                        )),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (input) => _con.user.email = input,
                      validator: (input) => !input.contains('@') ? S.of(context).should_be_a_valid_email : null,
                      decoration: InputDecoration(
                        labelText: S.of(context).email,
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
                    const Divider(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      onSaved: (input) => _con.user.password = input,
                      validator: (input) => input.length < 3 ? S.of(context).should_be_more_than_3_characters : null,
                      obscureText: _con.hidePassword,
                      decoration: InputDecoration(
                        labelText: S.of(context).password,
                        labelStyle: TextStyle(color: Theme.of(context).accentColor),
                        contentPadding: EdgeInsets.all(12),
                        hintText: '••••••••••••',
                        hintStyle: TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
                        prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).accentColor),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _con.hidePassword = !_con.hidePassword;
                            });
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
                        S.of(context).login,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        _con.login();
                      },
                    ),
//                    SizedBox(height: 15),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
                      },
                      shape: StadiumBorder(),
                      textColor: Theme.of(context).hintColor,
                      child: Text(S.of(context).skip),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    ),
//                      SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            child: Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/ForgetPassword');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text(S.of(context).forgot_password),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/SignUp');
                  },
                  textColor: Theme.of(context).hintColor,
                  child: Text(S.of(context).dont_have_an_account),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
