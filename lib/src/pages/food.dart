import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../src/elements/SimilarItemListWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:async';

import '../../generated/l10n.dart';
import '../controllers/food_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

// ignore: must_be_immutable
class FoodWidget extends StatefulWidget {
  RouteArgument routeArgument;

  FoodWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _FoodWidgetState createState() {
    return _FoodWidgetState();
  }
}

class _FoodWidgetState extends StateMVC<FoodWidget> {
  FoodController _con;
  Timer _timer;
  bool hasTimedout = false;

  _FoodWidgetState() : super(FoodController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForFood(foodId: widget.routeArgument.id, getAisle: true);
    _con.listenForCart();
    _con.listenForFavorite(foodId: widget.routeArgument.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasTimedout) {
      _timer = new Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => hasTimedout = true);
          _timer.cancel();
        }
      });
    }

    return Scaffold(
      key: _con.scaffoldKey,
      body: _con.food == null || _con.food?.image == null
          ? Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
          : SafeArea(
            child: RefreshIndicator(
              onRefresh: _con.refreshFood,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 125),
                    padding: EdgeInsets.only(bottom: 15),
                    child: CustomScrollView(
                      primary: true,
                      shrinkWrap: false,
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
                          expandedHeight: 300,
                          elevation: 0,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Hero(
                              tag: widget.routeArgument.heroTag ?? '' + _con.food.id,
                              child: CachedNetworkImage(
                                fit: BoxFit.contain,
                                imageUrl: _con.food.image.url,
                                placeholder: (context, url) => Image.asset(
                                  'assets/img/loading.gif',
                                  fit: BoxFit.contain,
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  'assets/img/image_default.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            child: Wrap(
                              runSpacing: 8,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            _con.food?.name ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.headline3,
                                          ),
                                          Text(
                                            'Category - ' + (_con.aisle == null ? 'Miscellaneous': _con.aisle.name),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: Theme.of(context).textTheme.headline5.merge(TextStyle(fontSize: 14)),
                                          ),
                                          Text(
                                            'Store - ' + _con.food.restaurant.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context).textTheme.bodyText2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Helper.getPrice(
                                            _con.food.price,
                                            context,
                                            style: Theme.of(context).textTheme.headline2,
                                          ),
                                          _con.food.discountPrice > 0
                                              ? Helper.getPrice(_con.food.discountPrice, context,
                                                  style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Colors.black, decoration: TextDecoration.lineThrough, fontSize: 15)))
                                              : SizedBox(height: 0),
                                          _con.food.weight == '0' || _con.food.weight == '' || _con.food.weight == "<p>.</p>"
                                              ? SizedBox(height: 0)
                                              : Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                              decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(24)),
                                              child: Text(
                                                _con.food.weight,
                                                style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
//                                    Container(
//                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
//                                      decoration: BoxDecoration(
//                                          color: Helper.canDelivery(_con.food.restaurant) && _con.food.deliverable ? Colors.green : Colors.orange,
//                                          borderRadius: BorderRadius.circular(24)),
//                                      child: Helper.canDelivery(_con.food.restaurant) && _con.food.deliverable
//                                          ? Text(
//                                              S.of(context).deliverable,
//                                              style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
//                                            )
//                                          : Text(
//                                              S.of(context).not_deliverable,
//                                              style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
//                                            ),
//                                    ),
//                                    Expanded(child: SizedBox(height: 0)),
//                                     Expanded(child: const SizedBox()),
                                    _con.food.featured
                                        ? Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(24)),
                                            child: Row (
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Theme.of(context).primaryColor,
                                                  size: 10,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  'Featured',
                                                  style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                                )
                                              ],
                                            )
                                          )
                                        : const SizedBox(),
                                    Expanded(child: const SizedBox()),
                                      // _con.aisle == null
                                      //   ? SizedBox(height: 0)
                                      //   : Container(
                                      //       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                      //       decoration: BoxDecoration(color: Colors.deepOrange, borderRadius: BorderRadius.circular(24)),
                                      //       child: Text(
                                      //         _con.aisle.name,
                                      //         style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                      //       )
                                      //     ),
                                  ],
                                ),
                                _con.food.description == '' ? SizedBox(height: 0,)
                                : Helper.applyHtml(context, _con.food.description, style: TextStyle(fontSize: 12)),
                                _con.food.nutritions.isEmpty
                                    ? SizedBox(height: 0)
                                    : ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    Icons.local_activity,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).nutrition,
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(_con.food.nutritions.length, (index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 6.0)]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(_con.food.nutritions.elementAt(index).name,
                                              overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.caption),
                                          Text(_con.food.nutritions.elementAt(index).quantity.toString(),
                                              overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headline5),
                                        ],
                                      ),
                                    );
                                  }),
                                ),

                                _con.similarItems == null || _con.similarItems.isEmpty
                                    ? hasTimedout
                                      ? const SizedBox(height: 200)
                                      : Column(
                                            children: <Widget>[
                                              Center(
                                                  heightFactor: 2,
                                                  child: SizedBox(
                                                      width: 60,
                                                      height: 60,
                                                      child:
                                                          CircularProgressIndicator(
                                                              strokeWidth: 5))),
                                              SizedBox(height: 300)
                                            ],
                                          )
                                    : ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    Icons.add_circle_outline,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).similar_items,
                                    style: Theme.of(context).textTheme.subtitle1,
                                  ),
                                ),
                                _con.similarItems == null || _con.similarItems.isEmpty
                                ? const SizedBox(height: 0)
                                : ListView.separated(
                                    padding: EdgeInsets.only(bottom: 80),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    primary: false,
                                    itemCount: _con.similarItems.length,
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: 10);
                                    },
                                    itemBuilder: (context, index) {
                                      return SimilarItemListWidget(
                                        food: _con.similarItems.elementAt(index),
                                      );
                                    },
                                  ),
//                                Helper.applyHtml(context, _con.food.ingredients, style: TextStyle(fontSize: 12)),




//                                ListTile(
//                                  dense: true,
//                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
//                                  leading: Icon(
//                                    Icons.recent_actors,
//                                    color: Theme.of(context).hintColor,
//                                  ),
//                                  title: Text(
//                                    S.of(context).reviews,
//                                    style: Theme.of(context).textTheme.subtitle1,
//                                  ),
//                                ),
//                                ReviewsListWidget(
//                                  reviewsList: _con.food.foodReviews,
//                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                  Positioned(
                    top: 32,
                    right: 20,
                    child: _con.loadCart
                        ? const SizedBox(
                            width: 60,
                            height: 60,
                            child: const RefreshProgressIndicator(),
                          )
                        : ShoppingCartFloatButtonWidget(
                            iconColor: Theme.of(context).primaryColor,
                            labelColor: Theme.of(context).hintColor,
                            food: _con.food,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 170,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    S.of(context).quantity,
                                    style: Theme.of(context).textTheme.subtitle1.apply(fontSizeFactor: 1.3),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () {
                                        _con.decrementQuantity();
                                      },
                                      iconSize: 35,
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      icon: Icon(Icons.remove_circle_outline),
                                      color: Theme.of(context).hintColor,
                                    ),
                                    Text(_con.quantity.toString(), style: Theme.of(context).textTheme.subtitle1.apply(fontSizeFactor: 1.5)),
                                    IconButton(
                                      onPressed: () {
                                        _con.incrementQuantity();
                                      },
                                      iconSize: 35,
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      icon: Icon(Icons.add_circle_outline),
                                      color: Theme.of(context).hintColor,
                                    )
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _con.favorite?.id != null
                                    ? FlatButton(
                                      onPressed: () {
                                        _con.removeFromFavorite(_con.favorite);
                                      },
                                      padding: EdgeInsets.symmetric(vertical: settingsRepo.compact_view_horizontal ? 12 : 20),
                                      color: Theme.of(context).accentColor,
                                      shape: StadiumBorder(),
                                      child: Icon(
                                        Icons.favorite,
                                        color: Theme.of(context).primaryColor,
                                      ))
                                   : OutlineButton(
                                      onPressed: () {
                                        if (currentUser.value.apiToken == null) {
                                          Navigator.of(context).pushNamed("/Login");
                                        } else {
                                          _con.addToFavorite(_con.food);
                                        }
                                      },
                                      padding: EdgeInsets.symmetric(vertical: settingsRepo.compact_view_horizontal ? 12 : 20),
                                      color: Theme.of(context).primaryColor,
                                      shape: StadiumBorder(),
                                      borderSide: BorderSide(color: Theme.of(context).accentColor),
                                      child: Icon(
                                        Icons.favorite,
                                        color: Theme.of(context).accentColor,
                                      )
                                  ),
                                ),
                                SizedBox(width: 10),
                                Stack(
                                  fit: StackFit.loose,
                                  alignment: AlignmentDirectional.centerEnd,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width - 110,
                                      height: 60,
                                      child: FlatButton(
                                        onPressed: () {
                                          addToCart();
                                        },
                                        padding: EdgeInsets.symmetric(vertical: 14),
                                        color: Theme.of(context).accentColor,
                                        shape: StadiumBorder(),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Text(
                                            S.of(context).add_to_cart,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: settingsRepo.compact_view_horizontal ? 15 : 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Helper.getPrice(
                                        _con.total,
                                        context,
                                        style: Theme.of(context).textTheme.headline4.merge(
                                            TextStyle(color: Theme.of(context).primaryColor, fontSize: settingsRepo.compact_view_horizontal ? 15 : 20)),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
      ),
    );
  }


  void addToCart() {
    if (currentUser.value.apiToken == null) {
      Navigator.of(context).pushNamed("/Login");
    } else {
      if (_con.isSameRestaurants(_con.food)) {
        _con.addToCart(_con.food);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AddToCartAlertDialogWidget(
                oldFood: _con.carts.elementAt(0)?.food,
                newFood: _con.food,
                onPressed: (food, {reset: true}) {
                  return _con.addToCart(_con.food, reset: true);
                });
          },
        );
      }
    }
  }

}
