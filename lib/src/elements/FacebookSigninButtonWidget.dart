import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saudaghar/src/helpers/size_config.dart';
import '../../src/controllers/user_controller.dart';
import '../../src/repository/settings_repository.dart' as settingsRepo;


class FacebookSigninButtonWidget extends StatelessWidget {
  final UserController con;
  final bool isLogin;
  FacebookSigninButtonWidget({Key key, this.con, this.isLogin = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () => con.initiateFacebookLogin(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.blue),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(
              "assets/img/facebook_icon.svg",
              color: Colors.blue,
              height: SizeConfig.HeightSize(55),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                isLogin ? 'Sign in with Facebook' : 'Sign up with Facebook',
                style: TextStyle(
                  fontSize: SizeConfig.FontSize(75),
                  color: Colors.blue,
                  letterSpacing: -0.2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
