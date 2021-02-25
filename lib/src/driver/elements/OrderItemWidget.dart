import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../generated/l10n.dart';
import '../../helpers/helper.dart';
import '../../models/order.dart';
import '../../models/route_argument.dart';
import 'FoodOrderItemWidget.dart';

class OrderItemWidget extends StatefulWidget {
  final Order order;

  OrderItemWidget({Key key, this.order}) : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
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
                      Text('${S.of(context).order_id}: #${widget.order.id}'),
                      Text(
                        widget.order.deliveryAddress.address,
                        style: Theme.of(context).textTheme.bodyText1.apply(fontSizeFactor: 0.8),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy | HH:mm').format(widget.order.created_at),
                        style: Theme.of(context).textTheme.caption,
                      ),
                      if (widget.order.orderStatus.id == '5')
                        Text(
                          'Delivery took ${widget.order.updated_at.difference(widget.order.created_at).inMinutes} minutes',
                          style: Theme.of(context).textTheme.caption.apply(color: Colors.redAccent),
                        ),
                      if (widget.order.hint != null) Text("Check Hint", style: Theme.of(context).textTheme.caption.apply(color: Theme.of(context).accentColor)),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headline4),
                      Text(
                        '${widget.order.payment.method}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  children: <Widget>[
                    Column(
                        children: List.generate(
                      widget.order.foodOrders.length,
                      (indexFood) {
                        return FoodOrderItemWidget(heroTag: 'mywidget.orders', order: widget.order, foodOrder: widget.order.foodOrders.elementAt(indexFood));
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
                              Helper.getPrice(widget.order.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
//                          Row(
//                            children: <Widget>[
//                              Expanded(
//                                child: Text(
//                                  '${S.of(context).tax} (${widget.order.tax}%)',
//                                  style: Theme.of(context).textTheme.bodyText1,
//                                ),
//                              ),
//                              Helper.getPrice(Helper.getTaxOrder(widget.order), context, style: Theme.of(context).textTheme.subtitle1)
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
                              Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headline4)
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
                      Navigator.of(context).pushNamed('/OrderDetails', arguments: RouteArgument(id: widget.order.id));
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
                  borderRadius: BorderRadius.all(Radius.circular(100)), color: widget.order.active ? widget.order.orderStatus.status_color : Colors.redAccent),
              alignment: AlignmentDirectional.center,
              child: Text(
                widget.order.active ? '${widget.order.orderStatus.status}' : S.of(context).canceled,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.caption.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor, fontSize: 10)),
              ),
            ),
            const Expanded(child: SizedBox()),
            if (widget.order.scheduled_time != null && widget.order.scheduled_time != "null")
              Container(
                margin: EdgeInsetsDirectional.only(end: 20),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: Colors.blue),
                alignment: AlignmentDirectional.center,
                child: Text(
                  'Deliver at: ${widget.order.scheduled_time}',
                  style: Theme.of(context).textTheme.caption.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor, fontSize: 10)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
