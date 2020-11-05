import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../models/food.dart';
import '../models/route_argument.dart';

class SimilarItemListWidget extends StatelessWidget {
  final Food food;

  const SimilarItemListWidget({Key key, this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Food', arguments: RouteArgument(id: food.id));
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
                child: Image.network(
                  food.image.thumb,
                  height: 60,
                  width: 60,
                ),
                // CachedNetworkImage(
                //   height: 60,
                //   width: 60,
                //   fit: BoxFit.cover,
                //   imageUrl: food.image.thumb,
                //   placeholder: (context, url) => Image.asset(
                //     'assets/img/loading.gif',
                //     fit: BoxFit.cover,
                //     height: 60,
                //     width: 60,
                //   ),
                //   errorWidget: (context, url, error) => Icon(Icons.error),
                // ),
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
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Helper.getPrice(food.price, context,
                          style: Theme.of(context).textTheme.caption
                      ),
                      food.weight == '0' || food.weight == '' ? SizedBox(height: 0)
                          : Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(24)),
                          child: Text(
                            food.weight + " " + food.unit,
                            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
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
