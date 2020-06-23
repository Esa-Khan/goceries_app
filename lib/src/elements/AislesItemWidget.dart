import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../models/category.dart' as category;

class AislesItemWidget extends StatefulWidget {
  final bool expanded;
  final category.Category aisle;

  AislesItemWidget({Key key, this.expanded, this.aisle}) : super(key: key);

  @override
  _AislesItemWidgetState createState() => _AislesItemWidgetState();
}

class _AislesItemWidgetState extends State<AislesItemWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14),
                padding: EdgeInsets.only(top: 20, bottom: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
                  ],
                ),
                child: Theme(
                  data: theme,
                  child: ExpansionTile(
                    initiallyExpanded: widget.expanded,
                    title: Column(
                      children: <Widget>[
                        Text("Test"),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    children: <Widget>[
//                      Column(
//                          children: List.generate(
//                        widget.order.foodOrders.length,
//                        (indexFood) {
//                          return FoodOrderItemWidget(
//                              heroTag: 'mywidget.orders', order: widget.order, foodOrder: widget.order.foodOrders.elementAt(indexFood));
//                        },
//                      )),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).delivery_fee,
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).submit,
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).total,
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Tracking');
                      },
                      textColor: Theme.of(context).hintColor,
                      child: Wrap(
                        children: <Widget>[Text(S.of(context).view)],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                    ),
                    if (true)
                      FlatButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: Wrap(
                                  spacing: 10,
                                  children: <Widget>[
                                    Icon(Icons.report, color: Colors.orange),
                                    Text(
                                      S.of(context).confirmation,
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ],
                                ),
                                content: Text(S.of(context).areYouSureYouWantToCancelThisOrder),
                                contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                                actions: <Widget>[
                                  FlatButton(
                                    child: new Text(
                                      S.of(context).yes,
                                      style: TextStyle(color: Theme.of(context).hintColor),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: new Text(
                                      S.of(context).close,
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        textColor: Theme.of(context).hintColor,
                        child: Wrap(
                          children: <Widget>[Text(S.of(context).cancel + " ")],
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 28,
//          width: 140,
          width: 190,
          alignment: AlignmentDirectional.center,
          child: Text(
            S.of(context).canceled,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.caption.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor)),
          ),
        ),
      ],
    );
  }
}
