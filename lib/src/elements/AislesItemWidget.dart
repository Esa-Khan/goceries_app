import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saudaghar/src/helpers/size_config.dart';
import '../../src/controllers/controller.dart';
import '../../src/controllers/category_controller.dart';
import '../../src/models/item.dart';
import '../../src/models/restaurant.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../models/category.dart' as category;
import 'FoodItemWidget.dart';
import '../controllers/category_controller.dart';

typedef expandAisle = void Function(category.Category);

class AislesItemWidget extends StatefulWidget {
  @override
  _AislesItemWidgetState createState() => _AislesItemWidgetState();
  final category.Category aisle;
  final List<category.Category> subAisles;
  final HashMap items;
  final expandAisle onPressed;
  final int timeout;

  AislesItemWidget({Key key, this.aisle, this.subAisles, this.items, this.onPressed, this.timeout}) : super(key: key);

 }

class _AislesItemWidgetState extends State<AislesItemWidget> {
  CategoryController _con = new CategoryController();
  double aisle_img_opacity = 1;
  bool first_load = true, timed_out = false;
  var sub_timed_out;

  @override
  void initState() {
    super.initState();
    if (first_load) {
      sub_timed_out = new List<bool>(widget.subAisles.length);
      for (int i = 0; i < widget.subAisles.length; i++) {
        sub_timed_out[i] = false;
      }
      first_load = false;
      _con.category = widget.aisle;
      // img_timeout();
      widget.subAisles.forEach((element) {
        _con.isExpandedList[element.id] = false;
        _con.isAisleLoadedList[element.id] = false;
      });
    }
  }

  // Future<void> img_timeout() async {
  //   if (mounted && !timed_out) {
  //     Future.delayed(Duration(milliseconds: ((widget.timeout)*900).ceil())).whenComplete(() {
  //       if (mounted) {
  //         // print("---------TIMEDOUT AFTER ${widget.timeout} SECONDS----------");
  //         setState(() => timed_out = true);
  //       }
  //     });
  //   }
  // }

  // Future<void> subimg_timeout(int index) async {
  //   if (mounted && !sub_timed_out[index]) {
  //     Future.delayed(Duration(milliseconds: ((index)*900).ceil())).whenComplete(() {
  //       if (mounted) {
  //         // print("---------SUB-TIMEDOUT AFTER ${index} SECONDS----------");
  //         setState(() => sub_timed_out[index] = true);
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical*40),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    // image: timed_out ? Image.network(widget.aisle.aisleImage).image : Image.asset('assets/img/loading.gif').image,
                    image: Image.network(widget.aisle.aisleImage).image,
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(Colors.white.withOpacity(aisle_img_opacity), BlendMode.dstIn),
                    onError: (dynamic, StackTrace) {
                      print("Error Loading Image: ${widget.aisle.aisleImage}");
                      // widget.aisle.aisleImage = 'assets/img/loading.gif';
                    },
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
                    trailing: Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white),
                    onExpansionChanged: (value) {
                      if (value) {
                        setState(() => aisle_img_opacity = 0.1);
                      } else {
                        setState(() => aisle_img_opacity = 1);
                      }
                      widget.onPressed(_con.category);
                    },
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.aisle.name,
                          style: TextStyle(
                              inherit: true,
                              fontSize: Theme.of(context).textTheme.headline2.fontSize,
                              color: Colors.white,
                              shadows: [
                                Shadow( // bottomLeft
                                    offset: Offset(-1.0, -1.0),
                                    color: Colors.black,
                                    blurRadius: 5
                                ),
                              ]
                          ),
                          maxLines: 1,
                          textScaleFactor: 1.3,
                        ),
                      ],
                    ),

                    children: <Widget>[
                      const SizedBox(height: 10),

                      widget.subAisles != null && widget.subAisles.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: false,
                          itemCount: widget.subAisles.length,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                          itemBuilder: (context, index) {
                            category.Category currSubAisle = widget.subAisles.elementAt(index);
                            List<Item> items = widget.items[currSubAisle.id];
                            // subimg_timeout(index);
                            if (widget.subAisles.length == 1) {
                              // Define a SubAisle dropdown
                              return ItemListWidget(items);
                            } else {
                              // Define a SubAisle dropdown
                              return SubCategoryItemWidget(
                                  index: index,
                                  currSubAisle: currSubAisle,
                                  items: items,
                                  theme: theme
                              );
                            }

                          },
                        )
                          : Center(heightFactor: 2,
                              child: SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(strokeWidth: 5))),
                      SizedBox(height: 20),
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




  Widget SubCategoryItemWidget({int index, category.Category currSubAisle,
                                  ThemeData theme, List<Item> items}) {
    return Stack(
        children: <Widget>[
          Opacity(
              opacity: 1,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(top: 14, left: 10, right: 10),
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              // image: sub_timed_out[index] && currSubAisle.aisleImage != null
                              //     ? Image.network(currSubAisle.aisleImage).image
                              //     : Image.asset('assets/img/loading.gif').image,
                              image: Image.network(currSubAisle.aisleImage).image,
                              fit: BoxFit.cover,
                              onError: (dynamic, StackTrace) {
                                print("Error Loading Image: ${currSubAisle.aisleImage}");
                                // currSubAisle.aisleImage = 'assets/img/loading.gif';
                              },
                            ),
                            color: Theme.of(context).primaryColor.withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                  color: Theme.of(context).focusColor.withOpacity(0.5),
                                  blurRadius: 5,
                                  offset: Offset(0, 2)
                              ),
                            ],
                            borderRadius: new BorderRadius.all(const Radius.circular(5.0))
                        ),
                        child: Theme(
                            data: theme,
                            child: ExpansionTile(
                                trailing: Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.white),
                                onExpansionChanged: (value) {
                                  widget.onPressed(currSubAisle);
                                },
                                title: Column(
                                  children: <Widget>[
                                    Text(
                                      currSubAisle.name,
                                      style: TextStyle(
                                          inherit: true,
                                          fontSize: Theme.of(context).textTheme.headline2.fontSize,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow( // bottomLeft
                                                offset: Offset(-1.0, -1.0),
                                                color: Colors.black,
                                                blurRadius: 5
                                            ),
                                          ]
                                      ),
                                      maxLines: 1,
                                      textScaleFactor: 1.3,
                                    ),
                                  ],
                                ),
                                children: <Widget>[
                                  const SizedBox(height: 10),
                                  ItemListWidget(items),
                                  SizedBox(height: 20),
                                ])))
                  ]))
        ]);
  }

  Widget ItemListWidget(List<Item> items) {
    return items == null || items.isEmpty
        ? Center(heightFactor: 2, child: const SizedBox(width: 60, height: 60,
        child: CircularProgressIndicator(strokeWidth: 5)))
        : ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            itemCount: items.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            // ignore: missing_return
            itemBuilder: (context, index) {
              return FoodItemWidget(
                heroTag: 'menu_list',
                food: items.elementAt(index),
              );
            },
          );
  }


}
