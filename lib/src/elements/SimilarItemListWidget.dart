import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:saudaghar/src/helpers/size_config.dart';

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

class SimilarItemListWidget extends StatelessWidget {
  final Food food;

  const SimilarItemListWidget({Key key, this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushReplacementNamed('/Food', arguments: RouteArgument(id: food.id));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.5), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: food.id,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                  imageUrl: food.image.thumb,
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
                ),
              ),
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
                          food.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 4,
                          style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(fontSize: SizeConfig.blockSizeHorizontal*30)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Helper.getPrice(food.price, context,
                      style: Theme.of(context).textTheme.headline4.merge(TextStyle(fontSize: 10)),
                      ),
                      food.weight == '0' || food.weight == '' ? SizedBox(height: 0)
                          : Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(24)),
                          child: Text(
                            food.weight + " " + food.unit,
                            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: 10)),
                          )),
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
}
