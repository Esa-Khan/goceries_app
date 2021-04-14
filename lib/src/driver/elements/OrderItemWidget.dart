import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../generated/l10n.dart';
import '../../helpers/helper.dart';
import '../../models/order.dart';
import '../../models/route_argument.dart';
import 'FoodOrderItemWidget.dart';

class OrderItemWidget extends StatelessWidget {
  final Order order;
  final String hero_tag;

  OrderItemWidget({Key key, this.order, this.hero_tag = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Stack(
      children: <Widget>[
        Column(
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
                  title: Column(
                    children: <Widget>[
                      Text('${S.of(context).order_id}: #${order.id}'),
                      order.deliveryAddress.address == null
                          ? Text(
                              'Address not found',
                              style: Theme.of(context).textTheme.bodyText1.apply(fontSizeFactor: 0.8, color: Colors.red),
                            )
                          : Text(
                              order.deliveryAddress.address,
                              style: Theme.of(context).textTheme.bodyText1.apply(fontSizeFactor: 0.8),
                            ),
                      if (hero_tag == 'history')
                        Text(
                          DateFormat('dd/MM/yyyy | HH:mm').format(order.created_at),
                          style: Theme.of(context).textTheme.caption,
                        ),
                      Text(
                        DateFormat('dd/MM/yyyy | HH:mm').format(hero_tag == 'history' ? order.updated_at : order.created_at),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      if (order.orderStatus.id == '5')
                        Text(
                          'Delivery took ${order.scheduled_time == null || order.scheduled_time == 'null' || DateTime.tryParse(order.scheduled_time) == null
                            ? order.updated_at.difference(order.created_at).inMinutes
                            : order.updated_at.difference(DateTime.tryParse(order.scheduled_time)).inMinutes} minutes',
                          style: Theme.of(context).textTheme.caption.apply(color: Colors.redAccent),
                        ),
                      if (order.hint != null) Text("Check Hint", style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).accentColor)),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Helper.getPrice(Helper.getTotalOrdersPrice(order), context, style: Theme.of(context).textTheme.headline4),
                      Text(
                        '${order.payment.method}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  children: <Widget>[
                    Column(
                        children: List.generate(
                      order.foodOrders.length,
                      (indexFood) {
                        return FoodOrderItemWidget(heroTag: 'mywidget.orders', order: order, foodOrder: order.foodOrders.elementAt(indexFood));
                      },
                    )),
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
                              Helper.getPrice(order.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
//                          Row(
//                            children: <Widget>[
//                              Expanded(
//                                child: Text(
//                                  '${S.of(context).tax} (${order.tax}%)',
//                                  style: Theme.of(context).textTheme.bodyText1,
//                                ),
//                              ),
//                              Helper.getPrice(Helper.getTaxOrder(order), context, style: Theme.of(context).textTheme.subtitle1)
//                            ],
//                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).total,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Helper.getPrice(Helper.getTotalOrdersPrice(order), context, style: Theme.of(context).textTheme.headline4)
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
                      Navigator.of(context).pushNamed('/OrderDetails', arguments: RouteArgument(id: order.id));
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Wrap(
                      children: <Widget>[Text(S.of(context).viewDetails), Icon(Icons.keyboard_arrow_right)],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsetsDirectional.only(start: 20),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100)), color: order.active ? order.orderStatus.status_color : Colors.redAccent),
              alignment: AlignmentDirectional.center,
              child: Text(
                order.active ? '${order.orderStatus.status}' : S.of(context).canceled,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.caption.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor, fontSize: 10)),
              ),
            ),
            const Expanded(child: SizedBox()),
            if (order.scheduled_time != null && order.scheduled_time != "null")
              Container(
                margin: EdgeInsetsDirectional.only(end: 20),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Colors.blue),
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Deliver at: ${order.scheduled_time}',
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor, fontSize: 10)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
