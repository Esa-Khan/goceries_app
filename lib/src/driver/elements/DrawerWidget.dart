import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/helpers/size_config.dart';

import '../../../generated/l10n.dart';
import '../../controllers/profile_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../../repository/settings_repository.dart';
import '../../repository/user_repository.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  //ProfileController _con;

  _DrawerWidgetState() : super(ProfileController()) {
    //_con = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Drawer(
      child: currentUser.value.apiToken == null
          ? CircularLoadingWidget(height: 500)
          : ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Pages', arguments: 0);
                  },
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
//              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35)),
                    ),
                    accountName: Text(
                      currentUser.value.name,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    accountEmail: Text(
                      currentUser.value.email,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Theme.of(context).accentColor,
                      backgroundImage: NetworkImage(currentUser.value.image.thumb),
                    ),
                  ),
                ),
                if (currentUser.value.id != null && currentUser.value.isDriver != null && currentUser.value.isManager != false)
                    ListTile(
                      leading: Switch(
                                onChanged: (value) => setState(() {
                                  currentUser.value.isDriver = !currentUser.value.isDriver;
                                  if (currentUser.value.isDriver) {
                                    Navigator.of(context)..pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: 1);
                                  } else {
                                    Navigator.of(context).pushNamedAndRemoveUntil('/StoreSelect', (Route<dynamic> route) => false);
                                  }
                                }),
                                value: currentUser.value.isDriver,
                                activeColor: Theme.of(context).accentColor,
                                inactiveThumbColor: Theme.of(context).primaryColor,
                              ),
                      title: Text(
                        'Driver View',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Pages', arguments: 1);
                  },
                  leading: Icon(
                    Icons.fastfood,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    S.of(context).orders,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Pages', arguments: 2);
                  },
                  leading: Icon(
                    Icons.history,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    S.of(context).history,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    S.of(context).application_preferences,
                    style: Theme.of(context).textTheme.headline2.merge(TextStyle(fontSize: SizeConfig.blockSizeHorizontal*40)),
                  ),
                  trailing: Icon(
                    Icons.remove,
                    color: Theme.of(context).focusColor.withOpacity(0.3),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Settings');
                  },
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    S.of(context).settings,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    if (Theme.of(context).brightness == Brightness.dark) {
                      setBrightness(Brightness.light);
                      setting.value.brightness.value = Brightness.light;
                    } else {
                      setting.value.brightness.value = Brightness.dark;
                      setBrightness(Brightness.dark);
                    }
                    setting.notifyListeners();
                  },
                  leading: Icon(
                    Icons.brightness_6,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    Theme.of(context).brightness == Brightness.dark ? S.of(context).light_mode : S.of(context).dark_mode,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    logout().then((value) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/Login', (Route<dynamic> route) => false);
                    });
                  },
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    S.of(context).log_out,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                setting.value.enableVersion
                  ? ListTile(
                      dense: true,
                      title: Text(
                        S.of(context).version + " " + version.value,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      trailing: Icon(
                        Icons.remove,
                        color: Theme.of(context).focusColor.withOpacity(0.3),
                      ),
                    )
                  : const SizedBox(),
              ],
            ),
    );
  }
}
