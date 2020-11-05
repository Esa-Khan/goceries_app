import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;

  HomeWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.getSaudaghar();
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
      body: settingsRepo.isStore.value == 1
          ? _con.saudaghar == null ? Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
              : CategoryListWidget(store: _con.saudaghar)
          : RefreshIndicator(
            onRefresh: _con.refreshHome,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      onClickFilter: (event) {
                        widget.parentScaffoldKey.currentState.openEndDrawer();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.stars,
                        color: Theme.of(context).hintColor,
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          getLocation();
                        },
                        icon: Icon(
                          Icons.my_location,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      title: Text(
                        settingsRepo.isStore.value == 2 ? 'Closest Stores' : 'Closest Restaurants',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(
                        settingsRepo.deliveryAddress.value?.address == null
                            ? "Tap the location icon to start"
                            : settingsRepo.deliveryAddress.value.address,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ),
                  CardsCarouselWidget(restaurantsList: _con.closestStores, heroTag: 'home_top_restaurants'),
                  SocialMediaOrdering(),
                  _con.categories.isEmpty ? const SizedBox()
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.category,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).aisles,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  _con.categories.isEmpty ? const SizedBox() : CategoriesCarouselWidget(categories: _con.categories),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      leading: Icon(
                        Icons.recent_actors,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).recent_reviews,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsListWidget(reviewsList: _con.recentReviews),
                  ),
                ],
              ),
            ),
          ),
    );
  }



  void getLocation() {
    if (currentUser.value.apiToken == null) {
      _con.requestForCurrentLocation(context);
    } else {
      var bottomSheetController = widget.parentScaffoldKey.currentState.showBottomSheet(
            (context) => DeliveryAddressBottomSheetWidget(scaffoldKey: widget.parentScaffoldKey),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
      );
      bottomSheetController.closed.then((value) {
        _con.refreshHome();
      });
    }
  }
}


class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          'https://thumbs.dreamstime.com/z/sale-off-offer-storewide-ramadan-background-eid-banner-discount-celebration-fantastic-festival-muslim-shopping-holiday-gift-up-148585574.jpg',
          height: 60,
          width: 60,
        )
//         CachedNetworkImage(
//           height: MediaQuery.of(context).size.height / 1.8,
//           width: MediaQuery.of(context).size.width / 1.3,
//           fit: BoxFit.cover,
//           imageUrl:
//               'https://thumbs.dreamstime.com/z/sale-off-offer-storewide-ramadan-background-eid-banner-discount-celebration-fantastic-festival-muslim-shopping-holiday-gift-up-148585574.jpg',
// //          imageUrl: 'https://goceries.org/storage/app/public/promotions.png',
//           placeholder: (context, url) => Image.asset(
//             'assets/img/loading.gif',
//             fit: BoxFit.contain,
//             width: double.infinity,
//             height: 82,
//           ),
//           errorWidget: (context, url, error) => const Icon(Icons.error),
//         ),
      ),
      elevation: 10,
      shape: const RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30.0))),
    );
  }
}
