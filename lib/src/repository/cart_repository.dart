import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<int> cart_count = new ValueNotifier(0);
ValueNotifier<String> currentCart_note = new ValueNotifier("");
ValueNotifier<String> currentCart_time = new ValueNotifier(null);

Future<Stream<Cart>> getCart() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}carts?${_apiToken}with=food;food.restaurant;extras&search=user_id:${_user.id}&searchFields=user_id:=';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Cart.fromJSON(data);
  });
}

Future<int> getCartCount() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return 0;
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url = '${GlobalConfiguration().getString('api_base_url')}carts/count?${_apiToken}search=user_id:${_user.id}&searchFields=user_id:=';

  final client = new http.Client();
  final response = await client.get(Uri.parse(url));

  return json.decode(response.body)['data'];
}


Future<Cart> addCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Cart();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  cart.user_id = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}carts/addcart?$_apiToken';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(cart.toMap()),
  );
  if (response.statusCode == 200) {
    return Cart.fromJSON(json.decode(response.body)['data']);
  } else if (response.statusCode == 404) {
    throw new Exception(json.decode(response.body)['message']);
  }
}

Future<Cart> updateCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Cart();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  cart.user_id = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}carts/${cart.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(cart.toMap()),
  );
  return Cart.fromJSON(json.decode(response.body)['data']);
}

Future<bool> removeCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return false;
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}carts/${cart.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.delete(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Helper.getBoolData(json.decode(response.body));
}


Future<int> clearCart() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return null;
  }
  final String url = '${GlobalConfiguration().getString('api_base_url')}carts/clearcart/${_user.id}?api_token=${_user.apiToken}';
  final client = new http.Client();
  final response = await client.delete(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Helper.getIntData(json.decode(response.body));
}

