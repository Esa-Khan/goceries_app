import 'package:flutter/widgets.dart';


class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static bool isLoaded = false;


  void init(BuildContext context) {
    if (!isLoaded) {
      _mediaQueryData = MediaQuery.of(context);
      screenWidth = _mediaQueryData.size.width;
      screenHeight = _mediaQueryData.size.height;
      blockSizeHorizontal = screenWidth / 1000;
      blockSizeVertical = screenHeight / 1000;
      isLoaded = true;
    }
  }

  static double HeightSize(double factor) {
    return blockSizeVertical * factor;
  }

  static double WidthSize(double factor) {
    return blockSizeHorizontal * factor;
  }

  static double FontSize(double factor) {
    return blockSizeHorizontal * blockSizeVertical * factor;
  }
}