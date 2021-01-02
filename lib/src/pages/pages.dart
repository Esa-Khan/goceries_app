import 'package:flutter/material.dart';
import '../../src/driver/pages/orders_history.dart';
import '../../src/pages/profile.dart';
import '../../src/repository/user_repository.dart';
import '../../src/pages/sg_home.dart';

import '../elements/DrawerWidget.dart';
import '../models/route_argument.dart';
import '../pages/favorites.dart';
import '../pages/home.dart';
import '../pages/map.dart';
import '../pages/notifications.dart';
import '../pages/orders.dart';
import '../repository/settings_repository.dart' as settingsRepo;

// ignore: must_be_immutable
class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  RouteArgument routeArgument;
  Widget currentPage = HomeWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PagesWidget({
    Key key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 2;
    }
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {
  initState() {
    super.initState();
    _selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      if (currentUser.value.isDriver != null && currentUser.value.isDriver) {
        widget.currentTab = tabItem == 3 ? 1 : tabItem;
        switch (tabItem) {
          case 0:
            widget.currentPage = ProfileWidget(parentScaffoldKey: widget.scaffoldKey);
            break;
          case 1:
            widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
            break;
          case 2:
            widget.currentPage = OrdersHistoryWidget(parentScaffoldKey: widget.scaffoldKey);
            break;
          case 3:
            widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
            break;
        }
      } else {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = NotificationsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
          break;
        case 2:
          if (settingsRepo.isStore.value == 0) {
            widget.currentPage = SGHomeWidget(parentScaffoldKey: widget.scaffoldKey);
          } else {
            widget.currentPage = HomeWidget(parentScaffoldKey: widget.scaffoldKey);
          }
          break;
        case 3:
          widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 4:
          widget.currentPage = FavoritesWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
      }
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        // endDrawer: FilterWidget(onFilter: (filter) {
        //   Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
        // }),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).accentColor,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab,
          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
                title: new Container(height: 5.0),
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 40, offset: Offset(0, 15)),
                      BoxShadow(color: Theme.of(context).accentColor.withOpacity(0.4), blurRadius: 13, offset: Offset(0, 3))
                    ],
                  ),
                  child: new Icon(Icons.home, color: Theme.of(context).primaryColor),
                )),
            BottomNavigationBarItem(
              icon: new Icon(Icons.fastfood),
              title: new Container(height: 0.0),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.favorite),
              title: new Container(height: 0.0),
            ),
          ],
        ),
      ),
    );
  }
}
