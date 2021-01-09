import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saudaghar/src/helpers/size_config.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

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
    await canLaunch(whatsappUrl)? launch(whatsappUrl) : print("Whatsapp ERROR: ${whatsappUrl}");
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
    SizeConfig().init(context);
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Help and Support",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          GridView.count(
            shrinkWrap: true,
            primary: true,
            physics: new NeverScrollableScrollPhysics(),
            // padding: EdgeInsets.symmetric(horizontal: settingRepo.compact_view_horizontal ? 40 : 50),
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeVertical*80),
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: 4,
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
                    padding: EdgeInsets.all(7),
                    // margin: EdgeInsets.all(settingRepo.compact_view_vertical ? 10 : 15),
                    margin: EdgeInsets.all(14 - SizeConfig.blockSizeHorizontal),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.9), blurRadius: 3, offset: Offset(0, 2)),
                      ],
                    ),
                    child: SvgPicture.asset(
                      logo_img.elementAt(index),
                      color: logo_color.elementAt(index),
                      fit: BoxFit.contain,
                    ),
                  )
              );
            }
            ),
          ),
        ],
      ),
    );
  }
}
