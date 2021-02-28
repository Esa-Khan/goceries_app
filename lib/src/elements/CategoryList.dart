import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/category.dart';
import 'AislesItemWidget.dart';




class CategoryList extends StatelessWidget {
  final List<Category> categories;
  final Restaurant store;

  CategoryList({Key key, this.categories, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return categories.isEmpty
        ? Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Center(
          child: SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(strokeWidth: 8))),
    )

        : ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            itemCount: categories.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 20);
            },
            itemBuilder: (context, index) {
              Category currAisle = categories.elementAt(index);
              // Define a Aisle dropdown
              return AislesItemWidget(
                aisle: currAisle,
                store: store,
              );
            }
          );
  }
}