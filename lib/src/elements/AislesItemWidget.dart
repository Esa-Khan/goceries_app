import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/pages/items_list.dart';
import '../models/restaurant.dart';
import '../controllers/sghome_controller.dart';
import '../helpers/size_config.dart';
import '../../src/models/item.dart';
import '../models/category.dart' as category;

typedef expandAisle = void Function(category.Category);

class AislesItemWidget extends StatefulWidget {
  @override
  _AislesItemWidgetState createState() => _AislesItemWidgetState();
  final category.Category aisle;
  final Restaurant store;

  AislesItemWidget({Key key, this.aisle, this.store}) : super(key: key);
}

class _AislesItemWidgetState extends StateMVC<AislesItemWidget> {
  SGHomeController _con = new SGHomeController();
  double aisle_img_opacity = 1;
  bool aisle_expanded = false;

  _AislesItemWidgetState() : super(SGHomeController()) {
    _con = controller;
  }


  @override
  void initState() {
    super.initState();

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
                      setState(() => widget.aisle.aisleImage = '${GlobalConfiguration().getString('base_url')}storage/app/public/aisles/misc.jpg');
                      // setState(() => widget.aisle.aisleImage);
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
                    trailing: Icon(aisle_expanded ? Icons.arrow_circle_up : Icons.arrow_drop_down_circle_outlined, color: Colors.white),
                    onExpansionChanged: (value) async {
                      setState(() => aisle_expanded != aisle_expanded);
                      if (value) {
                        if (_con.subcategories.isEmpty)
                          await _con.listenForSubCategories(widget.store.id, getSubCat: widget.aisle.id);
                        setState(() => aisle_img_opacity = 0.1);
                      } else {
                        setState(() => aisle_img_opacity = 1);
                      }
                      // widget.onPressed(_con.category);
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

                      _con.subcategories.isNotEmpty
                        ? ListView.separated(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemCount: _con.subcategories.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 10);
                            },
                            itemBuilder: (context, index) {
                              category.Category currSubAisle = _con.subcategories.elementAt(index);
                              return SubCategoryItemWidget(
                                  index: index,
                                  currSubAisle: currSubAisle,
                                  theme: theme
                              );
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
                          child: ListTile(
                            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
                            title: Text(
                              currSubAisle.name,
                              textAlign: TextAlign.center,
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
                            onTap: () => Navigator.of(context).push(_createRoute(currSubAisle)),
                          ),
                      )
                  )
                ]
            )
          )
        ]);
  }

  Route _createRoute(category.Category subCategory) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ItemsListWidget(store: widget.store, subAisle: subCategory),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.easeIn;
        var tween = Tween(begin: begin, end: end);
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );
        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }



}
