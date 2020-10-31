import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saudaghar/src/elements/CircularLoadingWidget.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;

class EmptyClosestStoreWidget extends StatefulWidget {
  EmptyClosestStoreWidget({
    Key key,
  }) : super(key: key);

  @override
  _EmptyClosestStoreWidgetState createState() => _EmptyClosestStoreWidgetState();
}

class _EmptyClosestStoreWidgetState extends State<EmptyClosestStoreWidget> {
  bool loading = true;

  @override
  void initState() {
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 200,
          alignment: AlignmentDirectional.center,
          padding: EdgeInsets.symmetric(horizontal: 30),
//          height: config.App(context).appHeight(70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                          Theme.of(context).accentColor.withOpacity(1),
                          Theme.of(context).accentColor.withOpacity(1),
                        ])),
                    child: Icon(
                      Icons.store_mall_directory,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: 70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Opacity(
                opacity: 0.4,
                child: Text(
                  "No stores near you. Coming soon!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3.merge(TextStyle(fontWeight: FontWeight.w300)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
