import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saudaghar/src/helpers/size_config.dart';
import '../../src/controllers/category_controller.dart';

import '../models/category.dart' as category;
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
  bool timed_out = false;
  var sub_timed_out;

  @override
  void initState() {
    super.initState();
    _con.category = widget.aisle;
  }


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
                  child: ListTile(
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                    title: Text(
                      widget.aisle.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          inherit: true,
                          fontSize: Theme.of(context).textTheme.headline2.fontSize,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(-1.0, -1.0),
                              color: Colors.black,
                              blurRadius: 5
                            ),
                          ]
                      ),
                      maxLines: 1,
                      textScaleFactor: 1.3,
                    ),
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
