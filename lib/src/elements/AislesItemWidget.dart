import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../models/category.dart' as category;
import 'FoodItemWidget.dart';

class AislesItemWidget extends StatefulWidget {
  final bool expanded;
  final category.Category aisle;
  final List<Food> foods;


  AislesItemWidget({Key key, this.expanded, this.aisle, this.foods})
      : super(key: key);

  @override
  _AislesItemWidgetState createState() => _AislesItemWidgetState();
}

class _AislesItemWidgetState extends State<AislesItemWidget> {

  @override
  void initState() {
    super.initState();
  }

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
                  image: DecorationImage(
                    image: AssetImage(widget.aisle.aisleImage),
                    fit: BoxFit.cover,
                  ),

                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.5),
                        blurRadius: 5,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Theme(
                  data: theme,
                  child: ExpansionTile(
//                    initiallyExpanded: widget.expanded,
                    title: Column(
                      children: <Widget>[
                        Text(
                          widget.aisle.name,
                          style: Theme.of(context).textTheme.headline2.apply(color: Theme.of(context).primaryColor),
                          maxLines: 1,
                          textScaleFactor: 1.3,
                        ),
                      ],
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
//                    trailing: Column(
//                      crossAxisAlignment: CrossAxisAlignment.end,
//                      mainAxisAlignment: MainAxisAlignment.center,
//                    ),
                    children: <Widget>[
//                      Column(
//                          children: List.generate(
//                        widget.order.foodOrders.length,
//                        (indexFood) {
//                          return FoodOrderItemWidget(
//                              heroTag: 'mywidget.orders', order: widget.order, foodOrder: widget.order.foodOrders.elementAt(indexFood));
//                        },
//                      )),
                      SizedBox(height: 10),
                      ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: widget.foods.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        // ignore: missing_return
                        itemBuilder: (context, index) {
                            return FoodItemWidget(
                              heroTag: 'menu_list',
//                              food: widget.foods.elementAt(index),
                              food: widget.foods.elementAt(index),
                            );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


}
