import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  String promotion = '';
  double subTotal = 0.0;
  double total = 0.0;
  bool notifyFreeDelivery = false;
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message}) async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
//      bool repeatingFood = false;
//      for (var currCart in carts){
//        if (currCart.food.id == _cart.food.id) {
//          currCart.quantity += _cart.quantity;
//          repeatingFood = true;
//          break;
//        }
//      }
//      if (!repeatingFood) {
        setState(() => carts.add(_cart));
//      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      // onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() => this.cartCount = _count);
    }, onError: (a) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    setState(() {
      carts = [];
    });
    listenForCarts(message: S.of(context).carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_food_was_removed_from_your_cart(_cart.food.name)),
        duration: Duration(seconds: 1),
      ));
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    carts.forEach((cart) {
      subTotal += cart.food.price * cart.quantity;
      cart.extras.forEach((element) {
        subTotal += element.price;
      });
    });
    if (Helper.canDelivery(carts[0].food.restaurant, carts: carts)) {
      deliveryFee = carts[0].food.restaurant.deliveryFee;
    }
    taxAmount = (subTotal + deliveryFee) * carts[0].food.restaurant.defaultTax / 100;
    if (subTotal < settingsRepo.setting.value.deliveryFeeLimit) {
      total = subTotal + deliveryFee;
      notifyFreeDelivery = true;
    } else {
      if (notifyFreeDelivery){
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).eligible_for_free_delivery),
          duration: Duration(seconds: 2),
        ));
      }
      notifyFreeDelivery = false;
      promotion == ""
        ? total = subTotal
        : total = subTotal - settingsRepo.setting.value.promo[promotion];
    }
    setState(() {});
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
    }
  }

  void goCheckout(BuildContext context) {
//    if (!currentUser.value.profileCompleted()) {
//    if (currentUser.value.profileCompleted()) {
//      scaffoldKey?.currentState?.showSnackBar(SnackBar(
//        content: Text(S.of(context).completeYourProfileDetailsToContinue),
//        action: SnackBarAction(
//          label: S.of(context).settings,
//          textColor: Theme.of(context).accentColor,
//          onPressed: () {
//            Navigator.of(context).pushNamed('/Settings');
//          },
//        ),
//      ));
//    } else {
    if (carts[0].food.restaurant.closed) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).this_restaurant_is_closed_),
      ));
    } else {
      Navigator.of(context).pushNamed('/DeliveryPickup');
    }
//    }
  }

}
