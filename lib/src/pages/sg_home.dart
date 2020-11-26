import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:saudaghar/src/elements/CategoryListWidget.dart';
import 'package:saudaghar/src/elements/SocialMediaOrdering.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/models/route_argument.dart';

import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class SGHomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;

  SGHomeWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);

  @override
  _SGHomeWidgetState createState() => _SGHomeWidgetState();
}

class _SGHomeWidgetState extends StateMVC<SGHomeWidget> {
  HomeController _con;
  bool first_load = true;
  _SGHomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    if (first_load) {
      first_load = false;
      _con.getSaudaghar();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: _con.saudaghar == null
            ? Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
            : CategoryListWidget(store: _con.saudaghar)
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
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
      elevation: 10,
      shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30.0))),
    );
  }
}
