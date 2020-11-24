import 'dart:async';

import 'package:flutter/material.dart';

class LogoLoadingWidget extends StatefulWidget {

  LogoLoadingWidget({Key key}) : super(key: key);

  @override
  _LogoLoadingWidgetState createState() => _LogoLoadingWidgetState();
}

class _LogoLoadingWidgetState extends State<LogoLoadingWidget> with SingleTickerProviderStateMixin {
  AnimationController rotationController;


  void initState() {
    super.initState();
    rotationController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    // Timer(Duration(seconds: 10), () {
    //   if (mounted) {
    //     rotationController.forward();
    //   }
    // });
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
      child: Image.asset('assets/img/logo.png', height: 150),
    );
  }
}
