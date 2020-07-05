import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class DeliveryPickupController extends CartController {
  GlobalKey<ScaffoldState> scaffoldKey;
  List<model.Address> deliveryAddress = new List<model.Address>();
  PaymentMethodList list;

  DeliveryPickupController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    super.listenForCarts();
//    listenForDeliveryAddress();
    listenForAddresses();
    print(settingRepo.deliveryAddress.value.toMap());
  }

  void listenForDeliveryAddress() async {
//    this.deliveryAddress = settingRepo.deliveryAddress.value;
    deliveryAddress.add(settingRepo.deliveryAddress.value);

  }

  void addAddress(model.Address address) {
    userRepo.addAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        deliveryAddress.add(value);
//        this.deliveryAddress = value;
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).new_address_added_successfully),
      ));
    });
  }

  void listenForAddresses({String message}) async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen((model.Address _address) {
      setState(() {
        bool repeatingAddress = false;
        this.deliveryAddress.forEach((element) {
          if (element.id == _address.id || element.address == _address.address){
            element = _address;
            repeatingAddress = true;
          }
        });
        if (!repeatingAddress){
          if (_address.isDefault){
//          deliveryAddress = _address;
            deliveryAddress.insert(0, _address);
          } else {
//          deliveryAddress = _address;
            deliveryAddress.add(_address);
          }
        } else {
          repeatingAddress = false;
        }
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
//        this.deliveryAddress = value;
        deliveryAddress.forEach((element) {
          if (element.id == value.id){
            element = value;
            return null;
          }
        });
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).details_updated_successfully),
      ));
    });
  }

  PaymentMethod getPickUpMethod() {
    return list.pickupList.elementAt(0);
  }

  PaymentMethod getDeliveryMethod() {
    return list.pickupList.elementAt(1);
  }

  void toggleDelivery({model.Address currAddress}) {
    PaymentMethod currPaymentMethod = getDeliveryMethod();
    list.pickupList.forEach((element) {
      if (element != currPaymentMethod) {
        element.selected = false;
      }
    });
    setState(() {
      if (currPaymentMethod.addressID == null || currPaymentMethod.addressID == currAddress.id || !currPaymentMethod.selected) {
        currPaymentMethod.selected = !currPaymentMethod.selected;
      } else {
        currPaymentMethod.selected = !currPaymentMethod.selected;
        currPaymentMethod.selected = !currPaymentMethod.selected;
      }
      if (currPaymentMethod.selected) {
        settingRepo.deliveryAddress.value = currAddress;
      }

      currPaymentMethod.addressID = currAddress.id;
    });
  }

  bool togglePickUp() {
    list.pickupList.forEach((element) {
      if (element != getPickUpMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getPickUpMethod().selected = !getPickUpMethod().selected;
    });
    if (getPickUpMethod().selected) {
      return true;
    } else {
      return false;
    }
  }

  PaymentMethod getSelectedMethod() {
      return list.pickupList.firstWhere((element) => element.selected);
  }

  @override
  void goCheckout(BuildContext context, [String time]) {
    try {
      Navigator.of(context).pushNamed(getSelectedMethod().route, arguments: RouteArgument(id: 'hint', param: time));
    } catch (e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).please_select_pickup_or_delivery),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
