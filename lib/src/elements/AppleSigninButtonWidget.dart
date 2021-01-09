import 'package:apple_sign_in/apple_sign_in_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../src/controllers/user_controller.dart';


class AppleSigninButtonWidget extends StatelessWidget {
  final UserController con;
  final bool isLogin;

  AppleSigninButtonWidget({Key key, this.con, this.isLogin = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
              blurRadius: 2,
              offset: Offset(0, 1)
          )
        ]
      ),

      child: AppleSignInButton(
        // style: ButtonStyle.black,
        type: ButtonType.continueButton,
        onPressed: con.signInWithApple,
      ),
    );
  }

}
