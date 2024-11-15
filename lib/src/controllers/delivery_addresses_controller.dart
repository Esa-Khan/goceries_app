import 'package:flutter/material.dart';
import '../../src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class DeliveryAddressesController extends ControllerMVC with ChangeNotifier {
  List<model.Address> addresses = <model.Address>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  Cart cart;

  DeliveryAddressesController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    if (settingRepo.deliveryAddress.value != null && settingRepo.deliveryAddress.value.id != "null")
      addresses.add(settingRepo.deliveryAddress.value);
    listenForAddresses();
    listenForCart();
  }

  void listenForAddresses({String message}) async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen((model.Address _address) {
        bool repeatingAddress = false;
        this.addresses.forEach((element) {
          if (element.id == _address.id || element.address == _address.address){
            element = _address;
            repeatingAddress = true;
          }
        });
        if (!repeatingAddress && _address.address != null && _address.id != null){
          if (_address.isDefault){
//          deliveryAddress = _address;
            setState(() => addresses.insert(0, _address));
          } else {
//          deliveryAddress = _address;
            setState(() => addresses.add(_address));
          }
        } else {
          repeatingAddress = false;
        }
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

//  void listenForAddresses({String message}) async {
//    final Stream<model.Address> stream = await userRepo.getAddresses();
//    stream.listen((model.Address _address) {
//      setState(() {
//        if (_address.isDefault){
//          addresses.insert(0, _address);
//        } else {
//          addresses.add(_address);
//        }
//      });
//    }, onError: (a) {
//      print(a);
//      scaffoldKey?.currentState?.showSnackBar(SnackBar(
//        content: Text(S.of(context).verify_your_internet_connection),
//      ));
//    }, onDone: () {
//      if (message != null) {
//        scaffoldKey?.currentState?.showSnackBar(SnackBar(
//          content: Text(message),
//        ));
//      }
//    });
//  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      cart = _cart;
    });
  }

  Future<void> refreshAddresses() async {
    addresses.clear();
    listenForAddresses(message: S.of(context).addresses_refreshed_successfuly);
  }

  Future<void> changeDeliveryAddress(model.Address address) async {
    await settingRepo.changeCurrentLocation(address);
    setState(() {
      settingRepo.deliveryAddress.value = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  Future<void> changeDeliveryAddressToCurrentLocation() async {
    model.Address _address = await settingRepo.setCurrentLocation();
    setState(() {
      settingRepo.deliveryAddress.value = _address;
      currentUser.value.address = _address.address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  void addAddress(model.Address address) {
    userRepo.addAddress(address).then((value) {
      setState(() {
        this.addresses.insert(0, value);
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).new_address_added_successfully),
      ));
    });
  }

  void chooseDeliveryAddress(model.Address address) {
    setState(() {
      settingRepo.deliveryAddress.value = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {});
      addresses.clear();
      listenForAddresses(message: S.of(context).the_address_updated_successfully);
    });
  }

  void removeDeliveryAddress(model.Address address) async {
    userRepo.removeDeliveryAddress(address).then((value) {
      setState(() {
        this.addresses.remove(address);
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).delivery_address_removed_successfully),
      ));
    });
  }
}
