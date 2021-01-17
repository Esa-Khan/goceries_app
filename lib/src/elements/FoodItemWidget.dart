import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingsRepo;
class FoodItemWidget extends StatelessWidget {
  final String heroTag;
  final Food food;

  const FoodItemWidget({Key key, this.food, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Food', arguments: RouteArgument(id: food.id, heroTag: this.heroTag));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(1),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.5), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: heroTag + food.id,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
             child: getItemIMG(),
              ),
            ),
            SizedBox(width: settingsRepo.compact_view_horizontal ? 5 : 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          food.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1.merge(TextStyle(fontSize: settingsRepo.compact_view_horizontal ? 13 : 15)),
                        ),
                        SizedBox(height: 5),

                        food.weight != "<p>.</p>" && food.weight.isNotEmpty && food.weight != "0"
                        ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration:
                          BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(24)),
                          child: Text(
                            food.weight,
                            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: settingsRepo.compact_view_horizontal ? 13 : 15)),
                          ),
                        )
                        : SizedBox(height: 0),
                        this.heroTag != 'store_search_list' && this.heroTag != 'store_list' && this.heroTag != 'menu_list'
                        ? Text(
                          food.restaurant.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: settingsRepo.compact_view_horizontal ? 13 : 15)),
                        )
                            : SizedBox(height: 0),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    children: <Widget>[
                      Helper.getPrice(food.price, context,
                          style: Theme.of(context).textTheme.headline4.merge(TextStyle(fontSize: settingsRepo.compact_view_horizontal ? 13 : 15))),
                      food.ingredients != "<p>.</p>" && food.ingredients.isNotEmpty && food.ingredients != "0"
                      ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration:
                        BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(24)),
                        child: Text(
                            S.of(context).add_options,
                          style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                        ),
                      )
                      : SizedBox(height: 0),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget getItemIMG() {
    CachedNetworkImage img;
    try {
       img = CachedNetworkImage(
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        imageUrl: food.image_url != null ? food.image_url : food.image.thumb,
        placeholder: (context, url) => Image.asset(
          'assets/img/loading.gif',
          fit: BoxFit.cover,
          height: 60,
          width: 60,
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/img/image_default.png',
          fit: BoxFit.cover,
          height: 60,
          width: 60,
        ),
      );
    } catch (e) {
      print('ERROR: Could not get item ${food.id}');
    }

    return  img;
  }

}
