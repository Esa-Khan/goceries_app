import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/controllers/controller.dart';
import 'package:food_delivery_app/src/controllers/category_controller.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
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

  AislesItemWidget({Key key, this.aisle, this.store, this.subAisles, this.items, this.onPressed}) : super(key: key);

 }

class _AislesItemWidgetState extends State<AislesItemWidget> {
  CategoryController _con = new CategoryController();
  double imageOpacity = 1;
  Image aisle_img = Image.asset('assets/img/loading.gif');
  HashMap subaisles_imgs = new HashMap<String, Image>();
  HashMap subaisles_imgs_loaded = new HashMap<String, bool>();
  bool _image_loaded = false;

  @override
  void initState() {
    super.initState();
    _con.category = widget.aisle;
    widget.subAisles.forEach((element) {
      _con.isExpandedList[element.id] = false;
      _con.isAisleLoadedList[element.id] = false;
      subaisles_imgs[element.id] = Image.asset('assets/img/loading.gif');
      subaisles_imgs_loaded[element.id] = false;
//      _con.subaisleToItemsMap[element.id] = new List<Food>();
    });

      getAisleImage();
  }

  void getAisleImage() async {
    if (!_image_loaded && _con.category?.aisleImage != null && mounted) {
      Image getIMG = await Image.network(_con.category.aisleImage);
//      await Future.delayed(Duration(milliseconds: int.parse(_con.category.id) * 100));
      setState(() {
        aisle_img = getIMG;
        _image_loaded = true;
      });
    }
  }

  void getSubAisleImage(category.Category aisle) async {
    if (!subaisles_imgs_loaded[aisle.id] && mounted) {
      Image getIMG = await Image.network(aisle.aisleImage);
//      await Future.delayed(Duration(milliseconds: int.parse(aisle.id)*10 - 1000));
      setState(() {
        subaisles_imgs[aisle.id] = getIMG;
        subaisles_imgs_loaded[aisle.id] = true;
      });
    }
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
                padding: EdgeInsets.only(top: 40, bottom: 40),
                decoration: BoxDecoration(
                  image: DecorationImage(
//                    image: aisle_img.image,//aisle_img.image,
                    image: aisle_img.image,
                    fit: BoxFit.cover,
                    colorFilter: new ColorFilter.mode(Colors.white.withOpacity(imageOpacity), BlendMode.dstIn),
                    onError: (dynamic, StackTrace) {
                      aisle_img = Image.asset('assets/img/loading.gif');
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
                    onExpansionChanged: (value) {
                      if (value) {
                        setState(() => imageOpacity = 0.1);
                      } else {
                        setState(() => imageOpacity = 1);
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

                      widget.subAisles != null && widget.subAisles?.isNotEmpty
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
                          category.Category currSubAisle = widget.subAisles.elementAt(index);
                          List<Food> items = widget.items[currSubAisle.id];
                          getSubAisleImage(currSubAisle);
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
                                            image: subaisles_imgs[currSubAisle.id].image,
//                                            image: NetworkImage(currSubAisle.aisleImage),
                                            fit: BoxFit.cover,
                                            onError: (dynamic, StackTrace) {
                                              setState(() => subaisles_imgs[currSubAisle.id] = Image.asset('assets/img/loading.gif'));
                                              print("Error Loading Image: ${currSubAisle.aisleImage}");
                                            },
                                          ),
                                          color: Theme.of(context).primaryColor.withOpacity(0.9),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context).focusColor.withOpacity(0.5),
                                                blurRadius: 5,
                                                offset: Offset(0, 2)),
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
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 5,
                                                    )))
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
