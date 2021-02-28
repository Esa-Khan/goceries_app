import 'dart:math';

import 'package:flutter/material.dart';
import 'package:saudaghar/src/elements/CustomRadioButtonWidget.dart';

class PointsCheckoutWidget extends StatelessWidget {
  @required final String herotag;
  @required final int points;
  final Function(int) setDiscount;

  const PointsCheckoutWidget({Key key, this.herotag, this.points, this.setDiscount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () => herotag == 'order_submitted' ? null : _showPointsDialog(context),
        child: Stack(
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
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: Offset(0, 0),
                    )
                  ],
                ),
                alignment: AlignmentDirectional.center,
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Theme
                          .of(context)
                          .primaryColor,
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
                transform: Matrix4.translationValues(-40, 0, 0)
                  ..rotateZ(-pi / 4.0),
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
                      'Use your loyalty points!',
                      style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: 7)),
                      textAlign: TextAlign.center,
                    )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  Future<int> _showPointsDialog(context) async {
    List<int> discounts = [1000, 5000, 10000, 50000];
    return showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Humaari treat!\nUse your points, get discounts',
                            style: Theme.of(context).textTheme.headline4.apply(color: Theme.of(context).accentColor),
                            textAlign: TextAlign.center
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 280,
                          width: 200,
                          child: ListView.builder(
                            itemCount: discounts.length,
                            itemBuilder: (context, index) {
                              return CustomRadioWidget(
                                text: discounts.elementAt(index).toString(),
                                disabled: discounts.elementAt(index) > points,
                                onChanged: () {
                                  setDiscount(discounts.elementAt(index));
                                  Navigator.of(context).pop();
                                }
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }
}


