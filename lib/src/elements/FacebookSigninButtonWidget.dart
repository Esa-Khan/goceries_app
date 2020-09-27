import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:food_delivery_app/src/controllers/user_controller.dart';


class FacebookSigninButtonWidget extends StatelessWidget {
  final UserController con;

  FacebookSigninButtonWidget({Key key, this.con}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        con.initiateFacebookLogin();
        SimpleDialog(
//            contentPadding: EdgeInsets.symmetric(horizontal: 20),
          titlePadding: EdgeInsets.fromLTRB(16, 25, 16, 0),
          title: Row(
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Theme.of(context).hintColor,
              ),
              Text(
                "Incorrect password",
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 10, 16, 0),
          children: <Widget>[
            Text(
              S.of(context).your_order_will_be_placed,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.blue),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "assets/img/facebook_icon.svg",
              color: Colors.blue,
              height: 35,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Facebook',
                style: TextStyle(
                  fontSize: 19,
                  color: Colors.blue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
