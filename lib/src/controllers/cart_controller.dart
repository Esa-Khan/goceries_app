import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/models/restaurant.dart';
import 'package:saudaghar/src/models/route_argument.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

class CartController extends ControllerMVC {
  Restaurant store;
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  String promotion = '';
  double subTotal = 0.0;
  double total = 0.0;
  bool notifyFreeDelivery = false;
  GlobalKey<ScaffoldState> scaffoldKey;
  bool item_unavail = false;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message}) async {
    setState(() => item_unavail = false);
    carts = <Cart>[];
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
        setState(() => carts.add(_cart));

    }, onError: (a) {
      print(a);
      showSnack(S.of(context).verify_your_internet_connection);
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
        store = carts.first.store;
        checkItemAvailabliity();
      }
      if (message != null)
        showSnack(message);
      // onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  bool cartcount_isLoaded = false;
  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        cart_count.value = _count;
        cart_count.notifyListeners();
        cartcount_isLoaded = true;
      });
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
    setState(() => carts.remove(_cart));
    removeCart(_cart).then((value) {
      cart_count.value--;
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
    if (carts.isNotEmpty) {
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
    }
    setState(() {});
  }

  bool show_snack_again = true;
  incrementQuantity(Cart cart) async {
    if (cart.quantity >= cart.food.quantity) {
      if (show_snack_again) {
        show_snack_again = false;
        showSnack('Only ${cart.food.quantity} of this item left in stock');
        Timer(Duration(seconds: 5), () {
          show_snack_again = true;
        });
      }
    } else if (cart.quantity <= 99) {
      if (cart.food.quantity < cart.quantity) {
        setState(() => item_unavail = true);
      } else {
        setState(() => item_unavail = false);
        ++cart.quantity;
        updateCart(cart);
        calculateSubtotal();
        checkItemAvailabliity();
      }
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      calculateSubtotal();
      checkItemAvailabliity();
    }
  }

  bool checkItemAvailabliity() {
    bool isAvail = true;
    for (int i = 0; i < carts.length; i++) {
      if (carts.elementAt(i).quantity > carts.elementAt(i).food.quantity) {
        isAvail = false;
        break;
      }
    }
    setState(() => item_unavail = !isAvail);
    return isAvail;
  }


  void goCheckout(BuildContext context) {
    if (carts[0].food.restaurant.closed) {
      showSnack(S.of(context).this_restaurant_is_closed_);
    } else {
      Navigator.of(context).pushNamed('/DeliveryPickup', arguments: RouteArgument(param: this));
    }
  }

  void showSnack(String message) {
    scaffoldKey?.currentState?.showSnackBar(SnackBar(
      content: Text(message, textAlign: TextAlign.center),
      duration: Duration(seconds: 1),
    ));
  }

}
