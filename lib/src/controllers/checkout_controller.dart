import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:saudaghar/src/helpers/maps_util.dart';
import '../../src/repository/cart_repository.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/credit_card.dart';
import '../models/food_order.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart';
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
  bool order_declined = false;
  String hint = "";
  String time = "";
  int delivery_time = null;
  GlobalKey<ScaffoldState> scaffoldKey;

  CheckoutController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  Future<void> getDeliveryTime() async {
    LatLng store = new LatLng(double.tryParse(carts.first.food.restaurant.latitude), double.tryParse(carts.first.food.restaurant.longitude));
    LatLng customer = new LatLng(deliveryAddress.value.latitude, deliveryAddress.value.longitude);
    // LatLng store = new LatLng(1, 1);
    // LatLng customer = new LatLng(1, 1);
    MapsUtil.getDeliveryTime(store, customer).then((value) => setState(() => delivery_time = value));
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
    _order.discount = setting.value.promo[promotion] ?? 0;
    _order.promotion = promotion == '' ? null : promotion;
    _order.hint = currentCart_note.value;
    _order.scheduled_time = currentCart_time.value;
    OrderStatus _orderStatus = new OrderStatus();
    _orderStatus.id = '1';
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = deliveryAddress.value;
    _order.deliveryFee = carts[0].food.restaurant.deliveryFee;
    carts.forEach((_cart) {
      FoodOrder _foodOrder = new FoodOrder();
      _foodOrder.quantity = _cart.quantity;
      _foodOrder.price = _cart.food.price;
      _foodOrder.food = _cart.food;
      _foodOrder.extras = _cart.extras;
      _order.foodOrders.add(_foodOrder);
    });
    if (Helper.getSubTotalOrdersPrice(_order) < setting.value.deliveryFeeLimit){
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
          order_declined = false;
        });
      }
    }).catchError((Object obj, StackTrace stackTrace) {
      // if (creditCard.number != '' && creditCard.cvc != '') {
      //   showDialog(
      //       context: context,
      //       builder: (context) => cardDeclinedDialog()
      //   );
      // }
      setState(() {
        order_submitted = false;
        loading = false;
        order_declined = true;
      });
    });
  }

  Widget cardDeclinedDialog() {
    return AlertDialog(
      title:  Wrap(
        spacing: 10,
        children: <Widget>[
          Icon(Icons.report, color: Colors.orange),
          Text(
            'Credit-card declined',
            style: TextStyle(color: Colors.orange, fontSize: 20),
          ),
        ],
      ),
      content: Text("Unfortunately your card ending with '${creditCard.number.substring(18)}' was declined, try checking your information or try a new credit-card."),
      actions: <Widget>[
        FlatButton(
          child: new Text(
              S.of(context).dismiss),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }

  Future<void> applePromotion(String code) async {
    bool isUsed = false;
    await orderRepo.checkCode(code).then((value) => isUsed = value);
    if (isUsed) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Code already used'),
        duration: Duration(seconds: 1),
      ));
    } else {
      if (subTotal < setting.value.promo[code]) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text('Subtotal must be greater than Rs.${setting.value.promo[code]} to use this promocode', textAlign: TextAlign.center),
          duration: Duration(seconds: 3),
        ));
      } else {
        if (promotion != '') {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text('Cannot use multiple promocodes'),
            duration: Duration(seconds: 1),
          ));
          total += setting.value.promo[promotion];
          promotion = code;
          if (total - setting.value.promo[promotion] > 0) {
            setState(() => total -= setting.value.promo[promotion]);
          }
          setState(() {
            promotion;
            total;
          });
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text('Discount added'),
            duration: Duration(seconds: 1),
          ));

          promotion = code;
          if (total - setting.value.promo[promotion] > 0) {
            setState(() => total -= setting.value.promo[promotion]);
          }
          setState(() {promotion; total;}
          );
        }

      }

    }

  }
}
