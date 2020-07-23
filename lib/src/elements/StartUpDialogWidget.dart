import 'package:flutter/material.dart';

import '../elements/GalleryItemWidget.dart';
import '../models/gallery.dart';

class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage('assets/tamas.jpg'),
                fit: BoxFit.cover
            )
        ),
      ),
    );
  }
}