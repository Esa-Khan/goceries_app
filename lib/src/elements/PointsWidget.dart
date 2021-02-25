
import 'dart:math';

import 'package:flutter/material.dart';

class PointsWidget extends StatelessWidget {
  @required final String herotag;
  @required final int points;
  const PointsWidget({Key key, this.herotag, this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack (
        children: [
          Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: 190,
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrangeAccent.withAlpha(170),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 0),
                  )
                ],
              ),
              alignment: AlignmentDirectional.center,
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    'Points: ',
                    style: Theme.of(context).textTheme.headline4.apply(color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(child: const SizedBox()),
                  Text(
                    points.toString(),
                    style: Theme.of(context).textTheme.headline2.apply(color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  Expanded(child: const SizedBox()),
                ],
              )
          ),
          Positioned(
            child: Transform(
              alignment: Alignment.topRight,
              transform: Matrix4.translationValues(-40, 0, 0)..rotateZ(-pi / 4.0),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withAlpha(170),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 0),
                      )
                    ],
                  ),
                  alignment: AlignmentDirectional.center,
                  child: Text(
                    'Spend More to Get More!',
                    style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: 7)),
                    textAlign: TextAlign.center,
                  )
              ),
            ),
          )
        ],
      ),
    );
  }


}
