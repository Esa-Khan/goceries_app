import 'dart:async';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/app_config.dart' as config;
import 'CircularLoadingWidget.dart';

class EmptyFavouritesWidget extends StatefulWidget {


  EmptyFavouritesWidget({Key key}) : super(key: key);

  @override
  _EmptyFavouritesWidgetState createState() => _EmptyFavouritesWidgetState();
}

class _EmptyFavouritesWidgetState extends State<EmptyFavouritesWidget> {
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
        loading
            ? Center(heightFactor: 2, child: SizedBox(width: 160, height: 160, child: CircularProgressIndicator(strokeWidth: 8)))
            : Container(
                alignment: AlignmentDirectional.center,
                padding: EdgeInsets.symmetric(horizontal: 30),
                height: config.App(context).appHeight(70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                                Theme.of(context).focusColor.withOpacity(0.7),
                                Theme.of(context).focusColor.withOpacity(0.05),
                              ])),
                          child: Icon(
                            Icons.favorite_border_rounded,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            size: 70,
                          ),
                        ),
                        Positioned(
                          right: -30,
                          bottom: -50,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(150),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -20,
                          top: -50,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(150),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        'No Favourites\n\nSubscription Service\nComing Soon!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline3.merge(TextStyle(fontWeight: FontWeight.w300)),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
        ),
      ],
    );
  }
}
