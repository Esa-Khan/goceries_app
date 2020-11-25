import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saudaghar/src/controllers/controller.dart';
import 'package:saudaghar/src/controllers/category_controller.dart';
import 'package:saudaghar/src/models/food.dart';
import 'package:saudaghar/src/models/restaurant.dart';
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
  final Restaurant store;
  final List<category.Category> subAisles;
  final HashMap items;
  final expandAisle onPressed;
  final int timeout;

  AislesItemWidget({Key key, this.aisle, this.store, this.subAisles, this.items, this.onPressed, this.timeout}) : super(key: key);

 }

class _AislesItemWidgetState extends State<AislesItemWidget> {
  CategoryController _con = new CategoryController();
  double aisle_img_opacity = 1;
  bool first_load = true, timed_out = false;

  @override
  void initState() {
    super.initState();
    if (first_load) {
      first_load = false;
      _con.category = widget.aisle;
      img_timeout();
      widget.subAisles.forEach((element) {
        _con.isExpandedList[element.id] = false;
        _con.isAisleLoadedList[element.id] = false;
      });
    }
  }

  Future<void> img_timeout() async {
      Future.delayed(Duration(milliseconds: ((widget.timeout/2)*1800).ceil())).whenComplete(() {
        print("---------TIMEDOUT AFTER ${widget.timeout} SECONDS----------");
        setState(() => timed_out = true);
      });
  }

  Future<bool> subimg_timeout(int time) async {
    Future.delayed(Duration(milliseconds: ((time/2)*1000).ceil())).whenComplete(() {
      print("---------SUB-TIMEDOUT AFTER ${time} SECONDS----------");
      return true;
    });
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
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: timed_out ? Image.network(widget.aisle.aisleImage).image : Image.asset('assets/img/loading.gif').image,
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(Colors.white.withOpacity(aisle_img_opacity), BlendMode.dstIn),
                    onError: (dynamic, StackTrace) {
                      widget.aisle.aisleImage = 'assets/img/loading.gif';
                      print("Error Loading Image: ${widget.aisle.aisleImage}");
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
                        // ignore: missing_return
                        itemBuilder: (context, index) {
                          // bool sub_timed_out = false;
                          // subimg_timeout(index).then((value) => setState(() => sub_timed_out = value));
                          category.Category currSubAisle = widget.subAisles.elementAt(index);
                          List<Food> items = widget.items[currSubAisle.id];
                          // Define a SubAisle dropdown
                          return Stack(
                            children: <Widget>[
                              Opacity(
                                opacity: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 14, left: 10, right: 10),
                                      padding: EdgeInsets.only(top: 20, bottom: 5),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                            // image: Image.network(widget.subAisles[int.parse(currSubAisle.id)].aisleImage).image,
                                           image: currSubAisle.aisleImage != null ? Image.network(currSubAisle.aisleImage).image : Image.asset('assets/img/loading.gif').image,
                                            fit: BoxFit.cover,
                                            onError: (dynamic, StackTrace) {
                                              print("Error Loading Image: ${currSubAisle.aisleImage}");
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
                                          borderRadius: new BorderRadius.only(
                                            topLeft: const Radius.circular(20.0),
                                            topRight: const Radius.circular(20.0),
                                            bottomLeft: const Radius.circular(20.0),
                                            bottomRight: const Radius.circular(20.0),
                                          )
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
                                            const SizedBox(height: 10),
                                            items == null || items.isEmpty
                                            ? Center(heightFactor: 2, child: SizedBox(width: 60, height: 60,
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
                                            ),
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
                        },
                      )
                          : Center(
                              heightFactor: 2,
                              child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
                                  ))),
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


}
