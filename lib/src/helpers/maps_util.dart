import 'dart:async';
import 'dart:convert';

import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../helpers/custom_trace.dart';
import '../models/Step.dart';
import '../repository/settings_repository.dart';
import '../models/address.dart';

class MapsUtil {
  static const BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?";

  static MapsUtil _instance = new MapsUtil.internal();

  MapsUtil.internal();

  factory MapsUtil() => _instance;
  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    return http.get(BASE_URL + url).then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;
//      print("API Response: " + res);
      if (statusCode < 200 || statusCode > 400 || json == null) {
        res = "{\"status\":" + statusCode.toString() + ",\"message\":\"error\",\"response\":" + res + "}";
        throw new Exception(res);
      }

      List<LatLng> steps;
      try {
        steps = parseSteps(_decoder.convert(res)["routes"][0]["legs"][0]["steps"]);
      } catch (e) {
        print(CustomTrace(StackTrace.current, message: e));
        // throw new Exception(e);
      }

      return steps;
    });
  }

  List<LatLng> parseSteps(final responseBody) {
    List<Step> _steps = responseBody.map<Step>((json) {
      return new Step.fromJson(json);
    }).toList();
    List<LatLng> _latLang = _steps.map((Step step) => step.startLatLng).toList();
    return _latLang;
  }

  static Future<String> getAddressName(LatLng location, String apiKey) async {
    try {
      var endPoint =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location?.latitude},${location?.longitude}&language=${setting.value.mobileLanguage.value}&key=$apiKey';
      var response = jsonDecode((await http.get(endPoint, headers: await LocationUtils.getAppHeaders())).body);

      return response['results'][0]['formatted_address'];
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
      return null;
    }
  }


  static Future<bool> withinRange(Address current_address, Address store_address, double range) async {
    bool isWithin = false;
    try {
      var endPoint =
          'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${current_address.latitude},${current_address.longitude}'
          '&destinations=${store_address.latitude},${store_address.longitude}&key=${setting.value.googleMapsKey}';
      var response = jsonDecode((await http.get(endPoint, headers: await LocationUtils.getAppHeaders())).body);
      // var value = response['rows'][0]['elements'][0]['distance']['value'];
      if (response['rows'][0]['elements'][0]['status'] == 'ZERO_RESULTS') {
        return isWithin;
      } else {
        int value = response['rows'][0]['elements'][0]['distance']['value'];
        print(value);
        isWithin = value < range*1000;
        return isWithin;
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
      return false;
    }

  }

  static Future<Address> getCurrentLocation() async {
    var location = new Location();
    Address _address = new Address();
    MapsUtil mapsUtil = new MapsUtil();
    await location.requestService();
    LocationData _locationData = await location.getLocation();
    String _addressName = await MapsUtil.getAddressName(new LatLng(_locationData?.latitude, _locationData?.longitude), setting.value.googleMapsKey);
    _address = Address.fromJSON({'address': _addressName, 'latitude': _locationData?.latitude, 'longitude': _locationData?.longitude});
    return _address;

  }

  static Future<int> getDeliveryTime(LatLng store, LatLng customer) async {
    try {
      var endPoint =
          'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=${store.latitude},${store.longitude}'
          '&destinations=${customer.latitude},${customer.longitude}&key=${setting.value.googleMapsKey}';
      var response = jsonDecode((await http.get(endPoint, headers: await LocationUtils.getAppHeaders())).body);
      // var value = response['rows'][0]['elements'][0]['distance']['value'];
      if (response['rows'][0]['elements'][0]['status'] == 'ZERO_RESULTS') {
        return -1;
      } else {
        int value = response['rows'][0]['elements'][0]['duration']['value'];
        return value;
      }
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
      return -1;
    }
  }


}
