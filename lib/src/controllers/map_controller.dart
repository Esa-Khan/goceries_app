import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/restaurant.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

class MapController extends ControllerMVC {
  Restaurant currentRestaurant;
  List<Restaurant> closestStores = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  Address currentAddress;
  Set<Polyline> polylines = new Set();
  CameraPosition cameraPosition;
  MapsUtil mapsUtil = new MapsUtil();
  Completer<GoogleMapController> mapController = Completer();

  void listenForNearRestaurants(Address myLocation, Address areaLocation) async {
    final Stream<Restaurant> stream = await getNearStores(myLocation, areaLocation);
    stream.listen((Restaurant _restaurant) {
      if (_restaurant.id != '0') {
        setState(() {
          if (_restaurant.distance < _restaurant.deliveryRange)
            closestStores.add(_restaurant);
        });
        Helper.getMarker(_restaurant.toMap()).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }
    }, onError: (a) {}, onDone: () {});
  }

  void getCurrentLocation() async {
    try {
      currentAddress = settingsRepo.deliveryAddress.value;
      setState(() {
        if (currentAddress.isUnknown()) {
          cameraPosition = CameraPosition(
            target: LatLng(40, 3),
            zoom: 4,
          );
        } else {
          cameraPosition = CameraPosition(
            target: LatLng(currentAddress.latitude, currentAddress.longitude),
            zoom: 14.4746,
          );
        }
      });
      if (!currentAddress.isUnknown()) {
        Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  void getRestaurantLocation() async {
    try {
      currentAddress = await settingsRepo.getCurrentLocation();
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(double.parse(currentRestaurant.latitude), double.parse(currentRestaurant.longitude)),
          zoom: 14.4746,
        );
      });
      Helper.getMyPositionMarker(currentAddress.latitude, currentAddress.longitude).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;

    settingsRepo.setCurrentLocation().then((_currentAddress) {
      setState(() {
        settingsRepo.deliveryAddress.value = _currentAddress;
        currentAddress = _currentAddress;
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_currentAddress.latitude, _currentAddress.longitude),
        zoom: 14.4746,
      )));
    });
  }

  void getRestaurantsOfArea() async {
    setState(() {
      closestStores = <Restaurant>[];
      Address areaAddress = Address.fromJSON({"latitude": cameraPosition.target.latitude, "longitude": cameraPosition.target.longitude});
      if (cameraPosition != null) {
        listenForNearRestaurants(currentAddress, areaAddress);
      } else {
        listenForNearRestaurants(currentAddress, currentAddress);
      }
    });
  }

  void getDirectionSteps() async {
    currentAddress = await settingsRepo.getCurrentLocation();
    mapsUtil
        .get("origin=" +
        currentAddress.latitude.toString() +
        "," +
        currentAddress.longitude.toString() +
        "&destination=" +
        currentRestaurant.latitude +
        "," +
        currentRestaurant.longitude +
        "&key=${settingsRepo.setting.value?.googleMapsKey}")
        .then((dynamic res) {
      if (res != null) {
        List<LatLng> _latLng = res as List<LatLng>;
        _latLng?.insert(0, new LatLng(currentAddress.latitude, currentAddress.longitude));
        setState(() {
          polylines.add(new Polyline(
              visible: true, polylineId: new PolylineId(currentAddress.hashCode.toString()), points: _latLng, color: config.Colors().mainColor(0.8), width: 6));
        });
      }
    });
  }

  Future refreshMap() async {
    setState(() {
      closestStores = <Restaurant>[];
    });
    listenForNearRestaurants(currentAddress, currentAddress);
  }
}