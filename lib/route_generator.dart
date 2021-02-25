import 'package:flutter/material.dart';
import 'src/driver/pages/pages.dart';
import 'src/driver/pages/notifications.dart';
import 'src/repository/user_repository.dart';
import 'src/pages/store_select.dart';

import 'src/models/route_argument.dart';
import 'src/pages/cart.dart';
import 'src/pages/category.dart';
import 'src/pages/checkout.dart';
import 'src/pages/debug.dart';
import 'src/pages/delivery_addresses.dart';
import 'src/pages/delivery_pickup.dart';
import 'src/pages/details.dart';
import 'src/pages/food.dart';
import 'src/pages/forget_password.dart';
import 'src/pages/help.dart';
import 'src/pages/languages.dart';
import 'src/pages/login.dart';
import 'src/pages/menu_list.dart';
import 'src/pages/order_success.dart';
import 'src/pages/pages.dart';
import 'src/pages/payment_methods.dart';
import 'src/pages/paypal_payment.dart';
import 'src/pages/profile.dart';
import 'src/pages/reviews.dart';
import 'src/pages/settings.dart';
import 'src/pages/signup.dart';
import 'src/pages/splash_screen.dart';
import 'src/pages/tracking.dart';

import 'src/driver/pages/order.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings, {String subTab}) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    if (currentUser.value.isDriver != null && currentUser.value.isDriver) {
      switch (settings.name) {
        case '/Pages':
          return MaterialPageRoute(builder: (_) => PagesTestWidget(currentTab: args));
        case '/OrderDetails':
          return MaterialPageRoute(builder: (_) => OrderWidget(routeArgument: args as RouteArgument));
        case '/Notifications':
          return MaterialPageRoute(builder: (_) => NotificationsWidget());
        case '/Languages':
          return MaterialPageRoute(builder: (_) => LanguagesWidget());
        case '/Help':
          return MaterialPageRoute(builder: (_) => HelpWidget());
        case '/Settings':
          return MaterialPageRoute(builder: (_) => SettingsWidget());

        default:
        // If there is no such named route in the switch statement, e.g. /third
        // return MaterialPageRoute(builder: (_) => Scaffold(body: SafeArea(child: Text('Route Error'))));
          print("Route Error");
          return MaterialPageRoute(builder: (_) => StoreSelectWidget());
      }
    } else {
      switch (settings.name) {
        case '/Debug':
          return MaterialPageRoute(builder: (_) => DebugWidget(routeArgument: args as RouteArgument));
        case '/Splash':
          return MaterialPageRoute(builder: (_) => SplashScreen());
        case '/SignUp':
          return MaterialPageRoute(builder: (_) => SignUpWidget());
        case '/MobileVerification':
          return MaterialPageRoute(builder: (_) => SignUpWidget());
        case '/MobileVerification2':
          return MaterialPageRoute(builder: (_) => SignUpWidget());
        case '/Login':
          return MaterialPageRoute(builder: (_) => LoginWidget());
        case '/Profile':
          return MaterialPageRoute(builder: (_) => ProfileWidget());
        case '/ForgetPassword':
          return MaterialPageRoute(builder: (_) => ForgetPasswordWidget());
        case '/Pages':
          return MaterialPageRoute(builder: (_) => PagesWidget(currentTab: args, subTab: subTab));
        case '/Details':
          return MaterialPageRoute(builder: (_) => DetailsWidget(routeArgument: args as RouteArgument));
        case '/Menu':
          return MaterialPageRoute(
              builder: (_) => MenuWidget(routeArgument: args as RouteArgument));
        case '/Item':
          return MaterialPageRoute(
              builder: (_) => FoodWidget(routeArgument: args as RouteArgument));
        case '/Category':
          return MaterialPageRoute(builder: (_) =>
              CategoryWidget(routeArgument: args as RouteArgument));
        case '/Cart':
          return MaterialPageRoute(
              builder: (_) => CartWidget(routeArgument: args as RouteArgument));
        case '/Tracking':
          return MaterialPageRoute(builder: (_) =>
              TrackingWidget(routeArgument: args as RouteArgument));
        case '/Reviews':
          return MaterialPageRoute(builder: (_) =>
              ReviewsWidget(routeArgument: args as RouteArgument));
        case '/PaymentMethod':
          return MaterialPageRoute(builder: (_) =>
              PaymentMethodsWidget(routeArgument: args as RouteArgument));
        case '/DeliveryAddresses':
          return MaterialPageRoute(builder: (_) => DeliveryAddressesWidget());
        case '/DeliveryPickup':
          return MaterialPageRoute(builder: (_) =>
              DeliveryPickupWidget(routeArgument: args as RouteArgument));
        case '/Checkout':
          return MaterialPageRoute(builder: (_) => CheckoutWidget());
        case '/CashOnDelivery':
          return MaterialPageRoute(builder: (_) =>
              OrderSuccessWidget(routeArgument: args as RouteArgument));
        case '/PayOnPickup':
          return MaterialPageRoute(builder: (_) =>
              OrderSuccessWidget(
                  routeArgument: RouteArgument(param: 'Pay on Pickup')));
        case '/PayPal':
          return MaterialPageRoute(builder: (_) =>
              PayPalPaymentWidget(routeArgument: args as RouteArgument));
        case '/OrderSuccess':
          return MaterialPageRoute(builder: (_) =>
              OrderSuccessWidget(routeArgument: args as RouteArgument));
        case '/Languages':
          return MaterialPageRoute(builder: (_) => LanguagesWidget());
        case '/Help':
          return MaterialPageRoute(builder: (_) => HelpWidget());
        case '/Settings':
          return MaterialPageRoute(builder: (_) => SettingsWidget());
        case '/StoreSelect':
          return MaterialPageRoute(builder: (_) => StoreSelectWidget());
        case '/DriverOrderDetails':
          return MaterialPageRoute(builder: (_) =>
              OrderWidget(routeArgument: args as RouteArgument));
        case '/Notifications':
          return MaterialPageRoute(builder: (_) => NotificationsWidget());

        default:
        // If there is no such named route in the switch statement, e.g. /third
          print("Route Error");
          // return MaterialPageRoute(builder: (_) => Scaffold(body: SafeArea(child: Text('Route Error'))));
          return MaterialPageRoute(builder: (_) => StoreSelectWidget());
      }
    }
  }
}