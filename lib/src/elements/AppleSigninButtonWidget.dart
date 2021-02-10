import 'package:apple_sign_in/apple_sign_in_button.dart' as appl;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../src/controllers/user_controller.dart';


class AppleSigninButtonWidget extends StatelessWidget {
  final UserController con;
  final bool isLogin;

  AppleSigninButtonWidget({Key key, this.con, this.isLogin = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      splashColor: Colors.grey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      onPressed: () { },
      child:  Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: appl.AppleSignInButton(
          type: isLogin ? appl.ButtonType.signIn : appl.ButtonType.continueButton,
          onPressed: con.signInWithApple,
          style: appl.ButtonStyle.white,
          cornerRadius: 40,
        ),
      )
    );
  }

}
