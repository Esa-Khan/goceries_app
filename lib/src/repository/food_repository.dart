import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/favorite.dart';
import '../models/filter.dart';
import '../models/item.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Item>> getTrendingFoods(Address address) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  filter.delivery = false;
  filter.open = false;
  _queryParams['limit'] = '6';
  _queryParams['trending'] = 'week';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}

Future<Stream<Item>> getFood(String foodId) async {
  Uri uri = Helper.getUri('api/foods/$foodId');
  uri = uri.replace(queryParameters: {'with': 'nutrition;restaurant;category;extras;extraGroups;foodReviews;foodReviews.user'});
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}


Future<Stream<Item>> getStoreItems(String storeID, {String limit, String id}) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  if (id != null)
    _queryParams['id'] = id;
  if (limit != null)
    _queryParams['limit'] = limit;

  _queryParams['restaurant_id'] = storeID;
  _queryParams['short'] = 'yes';

  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}


Future<Stream<Item>> getSimilarItems(String item_id) async {
  Uri uri = Helper.getUri('api/similaritems/${item_id}');
  // Map<String, dynamic> _queryParams = {};
  // _queryParams['id'] = item_id;
  //
  // uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}


Future<Stream<Item>> searchFoods(String search, Address address, {String storeID, String limit, String id, bool isStore}) async {
  if (search == null) search = "";
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = 'name:$search;description:$search;';
  _queryParams['searchFields'] = 'name:like;description:like';
  if (id != null)
    _queryParams['id'] = id;
  if (isStore != null)
    _queryParams['isStore'] = 'false';

  if (storeID != null && limit != null) {
    _queryParams['restaurant_id'] = storeID;
    _queryParams['limit'] = limit;
  } else if (storeID != null){
    _queryParams['restaurant_id'] = storeID;
  } else {
    _queryParams['limit'] = '10';
  }

  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }

  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}


Future<Stream<Item>> searchItemsInSubcategory({String search, String subcategoryID}) async {
  if (search == null) search = "";
  Uri uri = Helper.getUri('api/searchInSubcat');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = search;
  _queryParams['id'] = subcategoryID;

  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}


Future<Stream<Item>> getFoodsByCategory(categoryId, {storeID}) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, String> _queryParams = {};
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  if (storeID != null)
    _queryParams['restaurant_id'] = storeID;
  _queryParams['category_id'] = categoryId;
  _queryParams['short'] = 'true';

  // _queryParams = filter.toQuery(oldQuery: _queryParams);
  // uri = uri.replace(queryParameters: _queryParams);
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}

Future<Stream<Favorite>> isFavoriteFood(String foodId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites/exist?${_apiToken}food_id=$foodId&user_id=${_user.id}';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getObjectData(data)).map((data) => Favorite.fromJSON(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Favorite.fromJSON({}));
  }
}

Future<Stream<Favorite>> getFavorites() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites?${_apiToken}with=food;user;extras&search=user_id:${_user.id}&searchFields=user_id:=';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  try {
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) => Favorite.fromJSON(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Favorite.fromJSON({}));
  }
}

Future<Favorite> addFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  favorite.userId = _user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites?$_apiToken';
  try {
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(favorite.toMap()),
    );
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

Future<Favorite> removeFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites/${favorite.id}?$_apiToken';
  try {
    final client = new http.Client();
    final response = await client.delete(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

Future<Stream<Item>> getFoodsOfRestaurant(String restaurantId) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods?with=restaurant&search=restaurant.id:$restaurantId&searchFields=restaurant.id:=';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}

Future<Stream<Item>> getTrendingFoodsOfRestaurant(String restaurantId) async {
  Uri uri = Helper.getUri('api/foods');
  uri = uri.replace(queryParameters: {
    'with': 'restaurant',
    'search': 'restaurant_id:$restaurantId;featured:1',
    'searchFields': 'restaurant_id:=;featured:=',
  });
  // TODO Trending foods only
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}

Future<Stream<Item>> getFeaturedFoodsOfRestaurant(String storeID, {String limit, String id}) async {
  Uri uri = Helper.getUri('api/foods');
  Map<String, dynamic> _queryParams = {};
  uri = uri.replace(queryParameters: {
    'with': 'restaurant',
    'search': 'restaurant_id:$storeID;featured:1',
    'searchFields': 'restaurant_id:=;featured:=',
    'searchJoin': 'and',
  });
  _queryParams['with'] = 'restaurant';
  _queryParams['search'] = 'restaurant_id:$storeID;featured:1';
  _queryParams['searchFields'] = 'restaurant_id:=;featured:=';
  _queryParams['searchJoin'] = 'and';
  if (id != null)
    _queryParams['id'] = id;

  if (storeID != null && limit != null) {
    _queryParams['restaurant_id'] = storeID;
    _queryParams['limit'] = limit;
  } else if (storeID != null){
    _queryParams['restaurant_id'] = storeID;
  } else {
    _queryParams['limit'] = '10';
  }
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Item.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Item.fromJSON({}));
  }
}

Future<Review> addFoodReview(Review review, Item food) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}food_reviews';
  final client = new http.Client();
  review.user = userRepo.currentUser.value;
  try {
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(review.ofFoodToMap(food)),
    );
    if (response.statusCode == 200) {
      return Review.fromJSON(json.decode(response.body)['data']);
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
      return Review.fromJSON({});
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Review.fromJSON({});
  }
}





Future<Item> updateItem(Item item) async {
  final String _apiToken = 'api_token=${userRepo.currentUser.value.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods/${item.id}?$_apiToken';
  final client = new http.Client();
  try {
    final response = await client.put(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(item.toMap()),
    );
    return Item.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Item.fromJSON({});
  }
}
