import 'package:flutter/material.dart';
import '../../src/repository/settings_repository.dart' as settingRepo;
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/splash_screen_controller.dart';
import '../repository/user_repository.dart' as userRepo;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;
  bool isNotDone = true;
  SplashScreenState() : super(SplashScreenController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    loadData();
    userRepo.getCurrentUser();
  }

  void loadData() {
    _con.progress.addListener(() {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100 && isNotDone) {
        try {
          isNotDone = false;
          if (userRepo.currentUser.value.isDriver != null && userRepo.currentUser.value.isDriver) {
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
          } else {
            Navigator.of(context).pushReplacementNamed('/StoreSelect');
          }
        } catch (e) {}
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    settingRepo.compact_view_horizontal = MediaQuery.of(context).size.width < 380;
    settingRepo.compact_view_vertical = MediaQuery.of(context).size.height < 580;
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/img/logo.png',
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
