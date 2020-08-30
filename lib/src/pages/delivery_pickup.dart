import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/CircularLoadingWidget.dart';
import 'package:food_delivery_app/src/elements/DeliveryBottomDetailsWidget.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  DeliveryPickupWidget({Key key, this.routeArgument, this.parentScaffoldKey}) : super(key: key);


  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  DeliveryPickupController _con;

  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
      _con.listenForAddresses();
//      widget.pickup = widget.list.pickupList.elementAt(0);
//      widget.delivery = widget.list.pickupList.elementAt(1);
    }
    return Scaffold(
      key: _con.scaffoldKey,
      bottomNavigationBar: DeliveryBottomDetailsWidget(con: _con),
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).accentColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery,
          style: Theme.of(context).textTheme.headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
//            Padding(
//              padding: const EdgeInsets.only(left: 20, right: 10),
//              child: ListTile(
//                contentPadding: EdgeInsets.symmetric(vertical: 0),
//                leading: Icon(
//                  Icons.domain,
//                  color: Theme.of(context).hintColor,
//                ),
//                title: Text(
//                  S.of(context).pickup,
//                  maxLines: 1,
//                  overflow: TextOverflow.ellipsis,
//                  style: Theme.of(context).textTheme.headline4,
//                ),
//                subtitle: Text(
//                  S.of(context).select_to_pickup_your_food_from_the_store,
//                  maxLines: 1,
//                  overflow: TextOverflow.ellipsis,
//                  style: Theme.of(context).textTheme.caption,
//                ),
//              ),
//            ),
//            PickUpMethodItem(
//                paymentMethod: _con.getPickUpMethod(),
//                onPressed: (paymentMethod) {
//                  showDialog(context: context, builder: (BuildContext context) {return ConfirmationDialogBox(); });
//                  if (_con.togglePickUp())
//                    ConfirmationDialogBox(
//                      context: context,
//                    );
//                }),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 20, right: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.map,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).delivery,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: _con.carts.isNotEmpty &&
                        Helper.canDelivery(_con.carts[0].food.restaurant,
                            carts: _con.carts)
                        ? Text(
                      S.of(context).click_to_confirm_your_address_and_pay_or_long_press,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    )
                        : Text(S.of(context).deliveryMethodNotAllowed,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ),
                _con.carts.isNotEmpty &&
                    Helper.canDelivery(_con.carts[0].food.restaurant, carts: _con.carts)
//                ? ListView.separated(
//                    padding: EdgeInsets.symmetric(vertical: 15),
//                    scrollDirection: Axis.vertical,
//                    shrinkWrap: true,
//                    primary: false,
//                    itemCount: _conDeliveryAdresses.addresses.length,
//                    separatorBuilder: (context, index) {
//                      return SizedBox(height: 15);
//                    },
//                    itemBuilder: (context, index) {
//                      return DeliveryAddressesItemWidget(
//                        address: _conDeliveryAdresses.addresses.elementAt(index),
//                        onPressed: (Address _address) {
//                          DeliveryAddressDialog(
//                            context: context,
//                            address: _address,
//                            onChanged: (Address _address) {
//                              _con.updateAddress(_address);
//                            },
//                          );
//                        },
//                        onLongPress: (Address _address) {
//                          DeliveryAddressDialog(
//                            context: context,
//                            address: _address,
//                            onChanged: (Address _address) {
//                              _con.updateAddress(_address);
//                            },
//                          );
//                        },
//                        onDismissed: (Address _address) {
//                          _conDeliveryAdresses.removeDeliveryAddress(_address);
//                        },
//                      );
//                    },
//                )
                    ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _con.deliveryAddress.length,
                  shrinkWrap: true,
                  primary: false,
//                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  itemBuilder: (context, index) {
                    if (_con.deliveryAddress.elementAt(index).address != null && _con.deliveryAddress.elementAt(index).id != null) {
                      return DeliveryAddressesItemWidget(
                        paymentMethod: _con.getDeliveryMethod(),
                        address: _con.deliveryAddress.elementAt(index),
                        onPressed: (Address _address) {
                          if (_address.id == null || _address.id == 'null' || currentUser.value.phone == null || currentUser.value.phone == "") {
                            DeliveryAddressDialog(
                              context: context,
                              address: _address,
                              onChanged: (Address _address) {
                                _con.toggleDelivery(currAddress: _address);
//                              _con.addAddress(_address);
                              },
                            );

                          } else {
                            _con.toggleDelivery(currAddress: _address);
                          }
                        },
                        onLongPress: (Address _address) {
                          DeliveryAddressDialog(
                            context: context,
                            address: _address,
                            onChanged: (Address _address) {
                              _con.updateAddress(_address);
                            },
                          );
                        },
                        onDismissed: (Address _address) {
                          _con.removeDeliveryAddress(_address);
                        },
                      );
                    } else {
                      return SizedBox(height: 0);
                    }

                  },
                )
          : CircularLoadingWidget(height: 150),

                SizedBox(height: 30),
                InkWell(
                  splashColor: Theme.of(context).accentColor,
                  focusColor: Theme.of(context).accentColor,
                  highlightColor: Theme.of(context).primaryColor,
                  onTap: () async {
                    LocationResult result = await showLocationPicker(
                      context,
                      setting.value.googleMapsKey,
                      initialCenter: LatLng(deliveryAddress.value?.latitude ?? 0, deliveryAddress.value?.longitude ?? 0),
                      //automaticallyAnimateToCurrentLocation: true,
                      //mapStylePath: 'assets/mapStyle.json',
                      myLocationButtonEnabled: true,
                      //resultCardAlignment: Alignment.bottomCenter,
                    );
                    _con.addAddress(new Address.fromJSON({
                      'address': result.address,
                      'latitude': result.latLng.latitude,
                      'longitude': result.latLng.longitude,
                    }));
                    print("result = $result");
                    // Navigator.of(widget.scaffoldKey.currentContext).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).focusColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  color: Theme.of(context).primaryColor),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: Theme.of(context).accentColor,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).add_new_delivery_address,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: Theme.of(context).focusColor,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 5),

                InkWell(
                  splashColor: Theme.of(context).accentColor,
                  focusColor: Theme.of(context).accentColor,
                  highlightColor: Theme.of(context).primaryColor,
                  onTap: () {
                    _con.changeDeliveryAddressToCurrentLocation();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                            color:
                            Theme.of(context).focusColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Container(
                              height: 20,
                              width: 60,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                                  color: Theme.of(context).primaryColor),
                              child: Icon(
                                Icons.my_location,
                                color: Theme.of(context).accentColor,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).current_location,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: Theme.of(context).focusColor,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 90),





//                DeliveryAddressesItemWidget(
//                        paymentMethod: _con.getDeliveryMethod(),
//                        address: _con.deliveryAddress.first,
//                        onPressed: (Address _address) {
//                          if (_con.deliveryAddress.first.id == null ||
//                              _con.deliveryAddress.first.id == 'null' ||
//                              currentUser.value.phone == null) {
//                            DeliveryAddressDialog(
//                              context: context,
//                              address: _address,
//                              onChanged: (Address _address) {
//                                _con.addAddress(_address);
//                              },
//                            );
//                          } else {
//                            _con.toggleDelivery();
//                          }
//                        },
//                        onLongPress: (Address _address) {
//                          DeliveryAddressDialog(
//                            context: context,
//                            address: _address,
//                            onChanged: (Address _address) {
//                              _con.updateAddress(_address);
//                            },
//                          );
//                        },
//                      )
//                    : NotDeliverableAddressesItemWidget()
              ],
            )
          ],
        ),
      ),
    );
  }
}
