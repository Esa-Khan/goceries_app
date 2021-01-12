import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/controllers/freshhome_controller.dart';
import 'package:saudaghar/src/elements/FreshCategoryListWidget.dart';

import '../../src/models/route_argument.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class FreshHomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;

  FreshHomeWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);

  @override
  _FreshHomeWidgetState createState() => _FreshHomeWidgetState();
}

class _FreshHomeWidgetState extends StateMVC<FreshHomeWidget> {
  FreshHomeController _con;
  bool first_load = true;
  _FreshHomeWidgetState() : super(FreshHomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    if (first_load) {
      first_load = false;
      _con.getStore();
    }
  }

//void showPopup() async {
//  await showDialog(
//      context: context,
//      builder: (_) => ImageDialog()
//  );
//}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              currentUser.value.name == null ? value.appName : "Welcome " + currentUser.value.name?.split(" ")[0] + "!",
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: _con.store == null
            ? const Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
            : FreshCategoryListWidget(store: _con.store)
    );
  }
}


class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: CachedNetworkImage(
          height: MediaQuery.of(context).size.height / 1.8,
          width: MediaQuery.of(context).size.width / 1.3,
          fit: BoxFit.cover,
          imageUrl: "${GlobalConfiguration().getString('base_url')}storage/app/public/promotions.png",
          placeholder: (context, url) => Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.contain,
            width: double.infinity,
            height: 82,
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/img/image_default.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
          ),
        ),
      ),
      elevation: 10,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0))),
    );
  }
}