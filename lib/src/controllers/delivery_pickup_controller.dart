import 'package:flutter/material.dart';
import '../../src/helpers/helper.dart';
import '../../src/repository/user_repository.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';
import '../helpers/maps_util.dart';

class DeliveryPickupController extends CartController {
  GlobalKey<ScaffoldState> scaffoldKey;
  List<model.Address> deliveryAddress = new List<model.Address>();
  bool selectedAddress = false;
  PaymentMethodList list;
  bool loading = false;

  DeliveryPickupController() {
    // super.listenForCarts();
//    listenForDeliveryAddress();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForAddresses();
  }

  void listenForDeliveryAddress() async {
//    this.deliveryAddress = settingRepo.deliveryAddress.value;
    deliveryAddress.add(settingRepo.deliveryAddress.value);

  }

  void addAddress(model.Address address) {
    setState(() => loading = true);
    bool repeated_address = false;
    for (int i = 0; i < deliveryAddress.length; i++) {
      model.Address element = deliveryAddress.elementAt(i);
      if (element.address == address.address && element.longitude == address.longitude && element.latitude == address.latitude) {
        repeated_address = true;
        break;
      }
    };
    if (!repeated_address) {
      userRepo.addAddress(address).then((value) {
        setState(() {
          settingRepo.deliveryAddress.value = value;
          deliveryAddress.add(value);
//        this.deliveryAddress = value;
        });
      }).whenComplete(() {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).new_address_added_successfully),
          duration: Duration(milliseconds: 1500),
        ));
        setState(() => loading = false);
      });
    } else {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text('Address already added'),
        duration: Duration(milliseconds: 1500),
      ));
      setState(() => loading = false);
    }
  }

  void listenForAddresses({String message}) async {
    setState(() => loading = true);
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
        if (!repeatingAddress && _address.address != null && _address.longitude != null && _address.latitude != null){
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
      setState(() => loading = false);
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
      selectedAddress = currPaymentMethod.selected;
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
      Navigator.of(context).pushNamed(getSelectedMethod().route);
    } catch (e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).please_select_delivery),
        duration: Duration(seconds: 1),
      ));
    }
  }


  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    settingRepo.setCurrentLocation().then((_address) async {
      deliveryAddress.add(_address);
      currentUser.value.address = _address;
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> changeDeliveryAddressToCurrentLocation() async {
    setState(() => loading = true);
    scaffoldKey?.currentState?.showSnackBar(
      SnackBar(
        content: Text(S.of(context).getting_current_location),
        duration: Duration(seconds: 1),
      ));
    model.Address _address = await settingRepo.setCurrentLocation();
   if (_address.latitude != null && _address.longitude != null) {
      bool repeatedAddress = false;
      for (var currAddress in deliveryAddress) {
        if (!repeatedAddress && currAddress.address == _address.address) {
          repeatedAddress = true;
          break;
        }
      }
      if (!repeatedAddress) {
        addAddress(_address);
        settingRepo.deliveryAddress.value = _address;
        currentUser.value.address = _address.address;
        // deliveryAddress.add(_address);
      } else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).address_is_already_added),
          duration: Duration(seconds: 1),
        ));
      }
      settingRepo.deliveryAddress.notifyListeners();
      setState(() => loading = false);
   } else {
     scaffoldKey?.currentState?.showSnackBar(SnackBar(
       content: Text("Do not have permission. Allow location services in settings.", maxLines: 3),
       duration: Duration(seconds: 1),
     ));
   }
  }


  void removeDeliveryAddress(model.Address address) async {
    setState(() => loading = true);
    userRepo.deactivateDeliveryAddress(address).then((value) {
      setState(() {
        this.deliveryAddress.remove(address);
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).delivery_address_removed_successfully),
        duration: Duration(seconds: 1),
      ));
      setState(() => loading = false);
    });
  }


  void showSnackBar(String message) {
    scaffoldKey?.currentState?.showSnackBar(SnackBar(
      content: Text(message, textScaleFactor: 0.92),
      duration: Duration(milliseconds: 1500),
    ));
  }


  void showOutOfRangeSnack() {
    scaffoldKey?.currentState?.showSnackBar(SnackBar(
      content: Text('Address out of range'),
      duration: Duration(seconds: 1),
    ));
  }
}
