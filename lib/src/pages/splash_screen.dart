import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../src/repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:io' show Platform;
import '../controllers/splash_screen_controller.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:flutter_svg/flutter_svg.dart';


class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen> {
  SplashScreenController _con;
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
    _con.progress.addListener(() async {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        await versionCheck(context);
        try {
          if (userRepo.currentUser.value.isDriver != null && userRepo.currentUser.value.isDriver) {
            Navigator.of(context).pushReplacementNamed('/Pages', arguments: 1);
          } else {
            Navigator.of(context).pushReplacementNamed('/StoreSelect');
          }
        } catch (e) {
          print('ERROR: Error starting app');
          Navigator.of(context).pushReplacementNamed('/StoreSelect');
        }
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


  versionCheck(context) async {
    try {
      List <String> latest_version = Platform.isIOS
          ? setting.value.app_version_ios.split('.')
          : setting.value.app_version_android.split('.');
      List <String> current_version = version.value.split('.');
      bool prompt_to_update = false;
      print('Current Version: ${version.value} - ${Platform.isIOS ? setting.value.app_version_ios : setting.value.app_version_android}');
      for (int i = 0; i < current_version.length; i++) {
        if (int.parse(current_version[i]) < int.parse(latest_version[i])) {
          prompt_to_update = true;
          break;
        }
      }
      if (prompt_to_update) {
        await _showVersionDialog(context);
      }
    } catch (exception) {
      print('ERROR: Unable to fetch remote config. Cached or default values will be used');
    }
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "Bigger and Better!";
        String message = "There a newer version of the app available. For the best and uninterrupted experience, update now!";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabelCancel, style: Theme.of(context).textTheme.bodyText1),
                    onPressed: () => Navigator.pop(context),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    elevation: 4.0,
                    onPressed: () => _con.launchURL(),
                    child: Text(btnLabel, style: Theme.of(context).textTheme.bodyText1.apply(color: Theme.of(context).primaryColor)),
                    color: Theme.of(context).accentColor,
                  ),
                ],
              )
            : AlertDialog(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/img/update.svg",
                      color:Theme.of(context).accentColor,
                      height: 45,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ],
                ),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabelCancel, style: Theme.of(context).textTheme.bodyText1),
                    onPressed: () => Navigator.pop(context),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    elevation: 4.0,
                    onPressed: () => _con.launchURL(),
                    child: Text(btnLabel, style: Theme.of(context).textTheme.bodyText1.apply(color: Theme.of(context).primaryColor)),
                    color: Theme.of(context).accentColor,
                  ),
                ],
              );
      },
    );
  }


}
