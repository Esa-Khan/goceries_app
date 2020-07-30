import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/category_controller.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../models/category.dart' as category;
import 'FoodItemWidget.dart';
import '../controllers/category_controller.dart';

class AislesItemWidget extends StatefulWidget {
  @override
  _AislesItemWidgetState createState() => _AislesItemWidgetState();
  final category.Category aisle;
  final bool expanded;
  final Restaurant store;
  final List<Food> items;
  final VoidCallback onPressed;



  AislesItemWidget({Key key, this.expanded, this.aisle, this.store, this.items, this.onPressed}) : super(key: key);

 }

class _AislesItemWidgetState extends State<AislesItemWidget> {
  CategoryController _con = new CategoryController();


  @override
  void initState() {
    super.initState();
    _con.category = widget.aisle;
//    _con.listenForFoodsByCategory(id: widget.aisle.id, storeID: widget.store.id);
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
                    image: NetworkImage(widget.aisle.aisleImage),
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
                    onExpansionChanged: (bool) => widget.onPressed(),
                    title: Column(
                      children: <Widget>[
                        Text(
                          widget.aisle.name,
                          style: TextStyle(
                              inherit: true,
                              fontSize: Theme.of(context).textTheme.headline2.fontSize,
                              color: Theme.of(context).primaryColor,
                              shadows: [
                                Shadow( // bottomLeft
                                    offset: Offset(-0.5, -0.5),
                                    color: Colors.black
                                ),
                                Shadow( // bottomRight
                                    offset: Offset(0.5, -0.5),
                                    color: Colors.black
                                ),
                                Shadow( // topRight
                                    offset: Offset(0.5, 0.5),
                                    color: Colors.black
                                ),
                                Shadow( // topLeft
                                    offset: Offset(-0.5, 0.5),
                                    color: Colors.black
                                ),
                              ]
                          ),
                          maxLines: 1,
                          textScaleFactor: 1.3,
                        ),
                      ],
                    ),
                    children: <Widget>[
                      SizedBox(height: 10),
                      widget.items.isEmpty
                      ? Center(heightFactor: 2,
                          child: SizedBox( width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 5,)))
                      : ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: widget.items.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        // ignore: missing_return
                        itemBuilder: (context, index) {
                            return FoodItemWidget(
                              heroTag: 'menu_list',
                              food: widget.items.elementAt(index),
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
