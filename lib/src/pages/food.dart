import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:saudaghar/src/models/item.dart';
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
  TextEditingController name_controller;
  TextEditingController wgt_controller;
  TextEditingController qty_controller;

  _FoodWidgetState() : super(FoodController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForFood(foodId: widget.routeArgument.id, getAisle: true);
    _con.listenForCart();
    _con.listenForFavorite(foodId: widget.routeArgument.id);
    name_controller = TextEditingController();
    wgt_controller = TextEditingController();
    qty_controller = TextEditingController();
  }

  void dispose() {
    name_controller.dispose();
    wgt_controller.dispose();
    qty_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: _con.item == null || _con.item?.image == null
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
                              tag: widget.routeArgument.heroTag ?? '' + _con.item.id,
                              child: CachedNetworkImage(
                                fit: BoxFit.contain,
                                imageUrl: _con.item.image.url,
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
                                            _con.item?.name ?? '',
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
                                            'Store - ' + _con.item.restaurant.name,
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
                                            _con.item.price < _con.item.discountPrice
                                                ? _con.item.price
                                                : _con.item.discountPrice,
                                            context,
                                            style: Theme.of(context).textTheme.headline2,
                                          ),

                                          if (_con.item.price < _con.item.discountPrice && _con.item.discountPrice > 0)
                                            Helper.getPrice(_con.item.discountPrice, context,
                                                  style: Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Colors.black, decoration: TextDecoration.lineThrough, fontSize: 15))),

                                          if (_con.item.weight != '0' && _con.item.weight != '' && _con.item.weight != "<p>.</p>")
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                              decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(24)),
                                              child: Text(
                                                _con.item.weight,
                                                style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: 16)),
                                              )
                                            ),
                                          _con.item.quantity == 0
                                              ? Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 5),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius: BorderRadius.circular(24),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.red.withAlpha(125),
                                                          blurRadius: 2,
                                                          spreadRadius: 1,
                                                          offset: Offset(0, 0),
                                                        )
                                                      ],
                                                    ),
                                                    child: Text(
                                                      'Out of Stock',
                                                      style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                                    ),
                                                  ),
                                                )
                                              : _con.item.featured
                                                ? Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 5),
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.circular(24),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.green.withAlpha(125),
                                                            blurRadius: 2,
                                                            spreadRadius: 1,
                                                            offset: Offset(0, 0),
                                                          )
                                                        ],
                                                      ),
                                                      child: Row (
                                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                                    ),
                                                  )
                                                : const SizedBox()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (currentUser.value.isManager)
                                  InkWell(
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0)),
                                      elevation: 4.0,
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => getInvDialog()
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.inventory),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Inventory Management - ${_con.item.quantity} left',
                                            style: Theme.of(context).textTheme.subtitle1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),





                                if (_con.item.description != '' && _con.item.description != null)
                                  Helper.applyHtml(context, _con.item.description, style: TextStyle(fontSize: 12)),
                                if (_con.item.nutritions.isNotEmpty)
                                  ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                                  children: List.generate(_con.item.nutritions.length, (index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.all(Radius.circular(5)),
                                          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 6.0)]),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(_con.item.nutritions.elementAt(index).name,
                                              overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.caption),
                                          Text(_con.item.nutritions.elementAt(index).quantity.toString(),
                                              overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headline5),
                                        ],
                                      ),
                                    );
                                  }
                                  ),
                                ),

                                _con.loaded_similaritems
                                  ? ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                                      leading: Icon(
                                        Icons.list_alt_sharp,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      title: Text(
                                        S.of(context).similar_items,
                                        style: Theme.of(context).textTheme.headline3,
                                      ),
                                    )
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
                                      ),
                                if (_con.loaded_similaritems && _con.similarItems.isNotEmpty)
                                  ListView.separated(
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
                                  )
//                                Helper.applyHtml(context, _con.item.ingredients, style: TextStyle(fontSize: 12)),




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
//                                  reviewsList: _con.item.foodReviews,
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
                            food: _con.item,
                          ),
                  ),



                  // Bottom Nav
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 150,
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
                                      iconSize: 25,
                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                      icon: Icon(Icons.remove_circle_outline),
                                      color: Theme.of(context).hintColor,
                                    ),
                                    Text(_con.quantity.toString(), style: Theme.of(context).textTheme.subtitle1.apply(fontSizeFactor: 1.5)),
                                    IconButton(
                                      onPressed: () {
                                        _con.incrementQuantity();
                                      },
                                      iconSize: 25,
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
                                          _con.addToFavorite(_con.item);
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
                                        onPressed: _con.item.quantity > 0 ? () => addToCart() : null,
                                        disabledColor: Theme.of(context).focusColor.withOpacity(0.4),
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


  Widget getInvDialog() {
    Item new_food = _con.item;
    name_controller.text = _con.item.name;
    wgt_controller.text = _con.item.weight;
    qty_controller.text = _con.item.quantity.toString();
    bool submit_visible = false;
    bool loading_submit = false;

    return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            child: Wrap (
              alignment: WrapAlignment.center,
              runSpacing: 20,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory),
                      const SizedBox(width: 10),
                      Text(
                        'Inventory Management',
                        maxLines: null,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: TextField(
                          controller: name_controller,
                          keyboardType: TextInputType.text,
                          autocorrect: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.center,
                          style: Theme.of(context).textTheme.subtitle1,
                          decoration: new InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              prefixText: 'Name:    ',
                              counterText: "",
                              prefixStyle: Theme.of(context).textTheme.bodyText1
                          ),
                          onChanged: (String val) {
                            setState(() => submit_visible = true);
                            new_food.name = val;
                          }
                          ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: TextField(
                      controller: wgt_controller,
                      keyboardType: TextInputType.text,
                      autocorrect: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.subtitle1,
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          prefixText: 'Weight:   ',
                          counterText: "",
                          prefixStyle: Theme.of(context).textTheme.bodyText1
                      ),
                      onChanged: (String val) {
                        setState(() => submit_visible = true);
                        new_food.name = val;
                      }
                  ),
                ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (int.tryParse(qty_controller.text) > 0) {
                                  qty_controller.text = (int.tryParse(qty_controller.text) - 1).toString();
                                  setState(() => qty_controller.text == _con.item.quantity.toString() ? submit_visible = false : submit_visible = true);
                                }

                              },
                              iconSize: 30,
                              icon: Icon(Icons.remove_circle_outline),
                              color: Theme.of(context).hintColor,
                            ),
                            Expanded(
                                child: Container(
                                    height: 30.0,
                                    child: TextField(
                                      controller: qty_controller,
                                      maxLength: 4,
                                      maxLengthEnforced: true,
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      textAlign: TextAlign.center,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: Theme.of(context).textTheme.headline4,
                                      decoration: new InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                        counterText: "",
                                        prefixText: 'Quantity : ',
                                        prefixStyle: Theme.of(context).textTheme.headline4,
                                      ),
                                      onChanged: (String val) => setState(() => qty_controller.text == _con.item.quantity.toString() ? submit_visible = false : submit_visible = true),
                                    )
                                )
                            ),
                            IconButton(
                              onPressed: () {
                                if (int.tryParse(qty_controller.text) < 9999) {
                                  qty_controller.text = (int.tryParse(qty_controller.text) + 1).toString();
                                  setState(() => qty_controller.text == _con.item.quantity.toString() ? submit_visible = false : submit_visible = true);
                                }
                              },
                              iconSize: 30,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              icon: Icon(Icons.add_circle_outline),
                              color: Theme.of(context).hintColor,
                            ),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: submit_visible,
                        maintainState: true,
                        maintainAnimation: true,
                        maintainSize: true,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: loading_submit
                                ? Center(child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 4)))
                                : RaisedButton(
                                    elevation: 14.0,
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () async {
                                      new_food.quantity = qty_controller.toString().trim() == '' ? 0 : int.tryParse(qty_controller.text);
                                      new_food.name = name_controller.text;
                                      setState(() => loading_submit = true);
                                      await _con.updateItem(new_food);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        height: 40.0,
                                        width: 140.0,
                                        child: Text(
                                          "Submit Changes",
                                          style: TextStyle(color: Theme.of(context).accentColor),
                                        )
                                    ),
                            ),
                          ),

                        )
                      )

              ]
            )
          );
        }
        );
  }

  void addToCart() {
    if (currentUser.value.apiToken == null) {
      Navigator.of(context).pushNamed("/Login");
    } else {
      if (_con.isSameRestaurants(_con.item)) {
        _con.addToCart(_con.item);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AddToCartAlertDialogWidget(
                oldFood: _con.carts.elementAt(0)?.food,
                newFood: _con.item,
                onPressed: (item, {reset: true}) {
                  return _con.addToCart(_con.item, reset: true);
                });
          },
        );
      }
    }
  }

}

