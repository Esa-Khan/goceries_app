import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saudaghar/src/controllers/user_controller.dart';
import 'package:saudaghar/src/repository/settings_repository.dart' as settingsRepo;


class GoogleSigninButtonWidget extends StatelessWidget {
  final UserController con;
  final bool isLogin;

  GoogleSigninButtonWidget({Key key, this.con, this.isLogin = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Image(image: AssetImage("assets/img/google_logo.png"), height: settingsRepo.compact_view ? 30 : 35),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                isLogin ? 'Sign in with Google' : 'Sign up with Google',
                style: TextStyle(
                  fontSize: settingsRepo.compact_view ? 14 : 19,
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