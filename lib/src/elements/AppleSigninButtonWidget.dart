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
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
//        signInWithGoogle().whenComplete(() {
//          Navigator.of(context).push(
//            MaterialPageRoute(
//              builder: (context) {
//                return FirstScreen();
//              },
//            ),
//          );
//        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: AppleSignInButton(
        // style: ButtonStyle.black,
        type: ButtonType.continueButton,
      ),
    );
  }

}
