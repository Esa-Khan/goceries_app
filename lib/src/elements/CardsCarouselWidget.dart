import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saudaghar/src/helpers/size_config.dart';

import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart';
import 'EmptyClosestStoreWidget.dart';

// ignore: must_be_immutable
class CardsCarouselWidget extends StatefulWidget {
  List<Restaurant> restaurantsList;
  String heroTag;

  CardsCarouselWidget({Key key, this.restaurantsList, this.heroTag}) : super(key: key);

  @override
  _CardsCarouselWidgetState createState() => _CardsCarouselWidgetState();
}

class _CardsCarouselWidgetState extends State<CardsCarouselWidget> {
  bool hasTimedout = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasTimedout && widget.heroTag == 'home_top_restaurants')
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted)
          setState(() => hasTimedout = true);
      });

    return widget.restaurantsList.isEmpty
          ? hasTimedout && widget.heroTag == 'home_top_restaurants'
            ? EmptyClosestStoreWidget()
            : CardsCarouselLoaderWidget()
          : Container(
              height: 288,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.restaurantsList.length,
                itemBuilder: (context, index) {
                  if (widget.restaurantsList.elementAt(index).id == '0') {
                    return const SizedBox();
                  } else {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed('/Details',
                            arguments: RouteArgument(
                              id: widget.restaurantsList.elementAt(index).id,
                              heroTag: widget.heroTag,
                            ));
                      },
                      child: widget.restaurantsList.elementAt(index).availableForDelivery
                          ? CardWidget(restaurant: widget.restaurantsList.elementAt(index), heroTag: widget.heroTag)
                          : const SizedBox(),
                    );
                  }
                },
              ),
            );
  }
}
