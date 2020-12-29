import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../elements/CheckoutBottomDetailsWidget.dart';
import '../elements/CheckoutItemListWidget.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/payment.dart';
import '../models/route_argument.dart';

class OrderSuccessWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  OrderSuccessWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _OrderSuccessWidgetState createState() => _OrderSuccessWidgetState();
}

class _OrderSuccessWidgetState extends StateMVC<OrderSuccessWidget> {
  CheckoutController _con;

  _OrderSuccessWidgetState() : super(CheckoutController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    // route param contains the payment method
    _con.payment = new Payment(widget.routeArgument.param);
    _con.listenForCarts();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _con.order_submitted
                    ? Navigator.of(context).pushReplacementNamed('/Pages', arguments: 3)
                    : Navigator.of(context).pop,
        child: Scaffold(
          key: _con.scaffoldKey,
          bottomNavigationBar: CheckoutBottomDetailsWidget(con: _con),
          appBar: AppBar(
            automaticallyImplyLeading: false,
           leading: _con.order_submitted
                      ? const SizedBox()
                      : IconButton(
                           onPressed: () {
                             Navigator.of(context).pop();
                           },
                           icon: Icon(Icons.arrow_back),
                           color: Theme.of(context).hintColor,
                         ),
            centerTitle: true,
            title: Text(
              'Finalize Order',
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            ),
          ),
          body: _con.carts.isEmpty
              ? Center(heightFactor: 3.5, child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
              : SingleChildScrollView(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(width: 20),
                          Stack(
                            children: <Widget>[
                              Container(
                                width: settingsRepo.compact_view_horizontal ? 70 : 100,
                                height: settingsRepo.compact_view_horizontal ? 70 : 100,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        colors: _con.card_declined
                                            ? [Colors.red.withOpacity(0.2), Colors.red.withOpacity(1)]
                                            : [Theme.of(context).accentColor.withOpacity(0.2), Theme.of(context).accentColor.withOpacity(1)]
                                    )),
                                child: _con.order_submitted
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                        size: settingsRepo.compact_view_horizontal ? 40 : 55,
                                      )
                                    : _con.loading
                                      ? Padding(
                                          padding: EdgeInsets.all(settingsRepo.compact_view_horizontal ? 20 : 30),
                                          child: CircularProgressIndicator(
                                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).scaffoldBackgroundColor),
                                          ),
                                        )
                                      : _con.card_declined
                                        ? Icon(
                                            Icons.error_outline,
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            size: settingsRepo.compact_view_horizontal ? 40 : 55,
                                          )
                                        : Icon(
                                            Icons.local_grocery_store_outlined,
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            size: settingsRepo.compact_view_horizontal ? 40 : 55,
                                          )
                              ),
                              Positioned(
                                right: -30,
                                bottom: -50,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(150),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -20,
                                top: -50,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(150),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(width: 25),
                          Opacity(
                            opacity: 0.7,
                            child: Text(
                              _con.order_submitted
                                ? 'Order  Submitted!'
                                : _con.card_declined
                                  ? 'Card declined'
                                  : 'Ready to Checkout?',
                              style: Theme.of(context).textTheme.headline2.merge(
                                  TextStyle(fontWeight: FontWeight.bold,
                                            color: _con.card_declined
                                                ? Colors.red
                                                : Theme.of(context).accentColor,
                                            fontSize: settingsRepo.compact_view_horizontal ? 18 : 20
                                  )
                              ),
                            )
                            // _con.order_submitted
                            //     ? Text(
                            //         'Order  Submitted!',
                            //         style: Theme.of(context).textTheme.headline2.merge(
                            //             TextStyle(fontWeight: FontWeight.bold, color: Colors.green,
                            //                 fontSize: settingsRepo.compact_view_horizontal ? 18 : 20
                            //             )
                            //         ),
                            //       )
                            //     : Text(
                            //           'Ready to Checkout?',
                            //           style: Theme.of(context).textTheme.headline2.merge(
                            //               TextStyle(fontWeight: FontWeight.bold, color: Colors.red,
                            //                 fontSize: settingsRepo.compact_view_horizontal ? 18 : 20
                            //               )
                            //           ),
                            //         ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        // color: Theme.of(context).primaryColor,
                        // decoration: BoxDecoration(
                        //     color: Theme.of(context).primaryColor,
                        //     borderRadius: BorderRadius.circular(10),
                        //     boxShadow: [
                        //       BoxShadow(
                        //           color: Theme.of(context).focusColor.withOpacity(0.55),
                        //           offset: Offset(0, 5),
                        //           blurRadius: 5.0
                        //       )]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _con.carts.first.food.restaurant.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.headline3,
                            ),
                            Text(
                              'Payment by ' + _con.payment.method,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Colors.black54)),
                            ),
                            currentCart_time.value == null
                                ? const SizedBox()
                                : Text(
                                    'Scheduled Delivery:  ' + currentCart_time.value.toString().substring(0, 16),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Colors.black54, fontSize: 13)),
                                  ),
                            currentCart_note.value.isEmpty
                                ? const SizedBox()
                                : Text(
                                    'Note:  ' + currentCart_note.value,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                    style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: Colors.black54, fontSize: 13)),
                                  ),
                          ],
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          height: 1.0,
                          width: MediaQuery.of(context).size.width - 100,
                          color: Colors.black26
                        )),
                      ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _con.carts.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        itemBuilder: (context, index) {
                          return CheckoutItemListWidget(
                            heroTag: 'favorites_list',
                            cart_item: _con.carts.elementAt(index),
                          );
                        },
                      ),
                      const SizedBox(height: 50)
                    ],
                  ),
          )
      ));
  }
}
