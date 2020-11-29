import 'package:flutter/material.dart';
import 'package:saudaghar/src/repository/cart_repository.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/credit_card.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingsRepo;
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
  bool loading = false;
  bool order_submitted = false;
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
    super.onLoadingCartDone();
    if (payment != null) {
      setState(() => loading = true);
      addOrder(carts, hint);
    }
  }

  void addOrder(List<Cart> carts, String hint) async {
    Order _order = new Order();
    _order.foodOrders = new List<FoodOrder>();
    _order.discount = settingsRepo.setting.value.promo[promotion];
    _order.hint = currentCart_note.value;
    _order.scheduled_time = currentCart_time.value.toString();
    OrderStatus _orderStatus = new OrderStatus();
    _orderStatus.id = '1';
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = settingsRepo.deliveryAddress.value;
    _order.deliveryFee = carts[0].food.restaurant.deliveryFee;
    carts.forEach((_cart) {
      FoodOrder _foodOrder = new FoodOrder();
      _foodOrder.quantity = _cart.quantity;
      _foodOrder.price = _cart.food.price;
      _foodOrder.food = _cart.food;
      _foodOrder.extras = _cart.extras;
      _order.foodOrders.add(_foodOrder);
    });
    if (Helper.getTotalOrdersPrice(_order) < settingsRepo.setting.value.deliveryFeeLimit){
      _order.deliveryFee = payment.method == 'Pay on Pickup' ? 0 : carts[0].food.restaurant.deliveryFee;
    } else {
      _order.deliveryFee = 0;
    };
    orderRepo.addOrder(_order, this.payment).then((value) {
      currentCart_time.value = null;
      currentCart_note.value = '';

      if (value is Order) {
        setState(() {
          loading = false;
          order_submitted = true;
        });
      }
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }

  Future<bool> applePromotion(String code) async {
    bool isUsed = false;
    // await orderRepo.checkCode(code).then((value) => ;
    await orderRepo.checkCode(code).then((value) => isUsed = value);
    if (isUsed) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Code already used'),
        duration: Duration(seconds: 1),
      ));
    } else {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Discount added'),
        duration: Duration(seconds: 1),
      ));
      promotion = code;
      if (total - settingsRepo.setting.value.promo[promotion] > 0) {
        setState(() => total -= settingsRepo.setting.value.promo[promotion]);
      }
      setState(() {promotion; total;});
    }

  }
}
