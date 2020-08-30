import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/cart_repository.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/credit_card.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';
import '../helpers/helper.dart';
import '../controllers/cart_controller.dart';

class CheckoutController extends CartController {
  Payment payment;
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  double subTotal = 0.0;
  double total = 0.0;
  CreditCard creditCard = new CreditCard();
  bool loading = true;
  String hint = "";
  String time = "";
  GlobalKey<ScaffoldState> scaffoldKey;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  @override
  void onLoadingCartDone({String hint}) {
    if (payment != null) addOrder(carts, hint);
    super.onLoadingCartDone();
  }

  void addOrder(List<Cart> carts, String hint) async {
    Order _order = new Order();
    _order.foodOrders = new List<FoodOrder>();
    _order.tax = 0;//carts[0].food.restaurant.defaultTax;
    _order.hint = currentCart_note.value;
    _order.scheduled_time = currentCart_time.value.replaceAll(" ", "");
    OrderStatus _orderStatus = new OrderStatus();
    _orderStatus.id = '1';
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = settingRepo.deliveryAddress.value;
    _order.deliveryFee = carts[0].food.restaurant.deliveryFee;
    carts.forEach((_cart) {
      FoodOrder _foodOrder = new FoodOrder();
      _foodOrder.quantity = _cart.quantity;
      _foodOrder.price = _cart.food.price;
      _foodOrder.food = _cart.food;
      _foodOrder.extras = _cart.extras;
      _order.foodOrders.add(_foodOrder);
    });
    if (Helper.getTotalOrdersPrice(_order) < settingRepo.setting.value.deliveryFeeLimit){
      _order.deliveryFee = payment.method == 'Pay on Pickup' ? 0 : carts[0].food.restaurant.deliveryFee;
    } else {
      _order.deliveryFee = 0;
    };
    orderRepo.addOrder(_order, this.payment).then((value) {
      currentCart_note.value = "";
      currentCart_time.value = "";
      if (value is Order) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }
}
