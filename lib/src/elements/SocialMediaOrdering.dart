import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io' show Platform;
import 'package:food_delivery_app/src/elements/EmptyOrdersWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart';
import 'EmptyClosestStoreWidget.dart';
import '../repository/settings_repository.dart' as settingRepo;

// ignore: must_be_immutable
class SocialMediaOrdering extends StatefulWidget {

  SocialMediaOrdering({Key key})
      : super(key: key);

  @override
  _SocialMediaOrderingState createState() => _SocialMediaOrderingState();
}

class _SocialMediaOrderingState extends State<SocialMediaOrdering> {
  List<String> logo_img = ['assets/img/whatsapp_icon.svg', 'assets/img/facebook_icon.svg', 'assets/img/instagram_icon.svg', 'assets/img/PhoneSMS.svg'];
  List<Color> logo_color = [Colors.green, Colors.blue, Colors.pinkAccent, Colors.orange];
  String phone = "+923248089044";
  @override
  void initState() {
    super.initState();
  }

  Future<void> launchWA() async {
    var whatsappUrl ="whatsapp://send?phone=${settingRepo.setting.value.whatsapp_number}";
    await canLaunch(whatsappUrl)? launch(whatsappUrl):print("open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
  }
  Future<void> launchFB() async {
    String fbProtocolUrl;
    String fbID = settingRepo.setting.value.facebook_url.split('-').elementAt(1);
    if (Platform.isIOS) {
      fbProtocolUrl = 'fb://profile/$fbID';
    } else {
      fbProtocolUrl = 'fb://page/$fbID';
    }
    String fallbackUrl = 'https://www.facebook.com/${settingRepo.setting.value.facebook_url}';
    try {
      bool launched = await launch(fbProtocolUrl, forceSafariVC: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false);
    }
  }

  Future<void> launchIG() async {
    var url = settingRepo.setting.value.instagram_url;
    if (await canLaunch(url)) {
      await launch(
        url,
        universalLinksOnly: true,
      );
    } else {
    throw 'There was a problem to open the url: $url';
    }
  }

  void launchCall() {
    launch("tel:${settingRepo.setting.value.phone_number}");
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 5),
              leading: Icon(
                Icons.contact_phone,
                color: Theme.of(context).hintColor,
              ),
              title: Text(
                "Order from anywhere!",
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                "Problem with the app?  Find help and order from anywhere!",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Offstage(
              offstage: false,
                child: GridView.count(
//              scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: true,
                  physics: new NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? 2
                          : 4,
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(logo_color.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        switch(index) {
                          case 0:
                            launchWA();
                            break;
                          case 1:
                            launchFB();
                            break;
                          case 2:
                            launchIG();
                            break;
                          case 3:
                            launchCall();
                            break;
                        }

                      },
                        child: Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.1),
                              blurRadius: 15,
                              offset: Offset(0, 5)),
                        ],
                      ),
                      child: SvgPicture.asset(
                        logo_img.elementAt(index),
                        color: logo_color.elementAt(index),
                        height: MediaQuery.of(context).size.width / 2 - 50,
                        fit: BoxFit.contain,
                      ),
                    ));
                  }),
              )),
          Divider(height: 30),
        ],
      ),
    );
  }
}
