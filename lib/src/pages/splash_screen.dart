import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:saudaghar/src/helpers/size_config.dart';
import '../../src/repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:io' show Platform;
import '../controllers/splash_screen_controller.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

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
    checkForUpdate();
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
    compact_view_horizontal = MediaQuery.of(context).size.width < 380;
    compact_view_vertical = MediaQuery.of(context).size.height < 580;
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



  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    if (Platform.isIOS){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return UpgradeAlert(
            debugLogging: true,
            child: Center(child: Text('Checking...')),
          );
        },
      );
    } else {
      InAppUpdate.checkForUpdate().then((info) {
        if (info?.updateAvailable == true) {
          InAppUpdate.performImmediateUpdate().catchError((e) => print('ERROR: ${e.toString()}'));
        }
      }).catchError((e) => print('ERROR: ' + e.toString()));
    }
  }


}
