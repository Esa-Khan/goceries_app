import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saudaghar/src/helpers/size_config.dart';
import '../../src/controllers/user_controller.dart';
import '../../src/repository/settings_repository.dart' as settingsRepo;


class GoogleSigninButtonWidget extends StatelessWidget {
  final UserController con;
  final bool isLogin;

  GoogleSigninButtonWidget({Key key, this.con, this.isLogin = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        con.signInWithGoogle();
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image(image: AssetImage("assets/img/google_logo.png"),
                  height: SizeConfig.WidthSize(90).clamp(0, 30).ceilToDouble(),
    ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                isLogin
                    ? 'Sign in with Google'
                    : con.supportsAppleSignIn
                      ? 'Continue with Google'
                      : 'Sign up with Google',
                style: TextStyle(
                  fontSize: isLogin ? (SizeConfig.blockSizeHorizontal*45).clamp(0, 25).toDouble() : (SizeConfig.blockSizeHorizontal*45).clamp(0, 25).toDouble(),
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
