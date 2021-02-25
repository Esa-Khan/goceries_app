import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomRadioWidget<T> extends StatelessWidget {
  final void Function() onChanged;
  final bool disabled;
  final double width;
  final double height;
  final String text;

  CustomRadioWidget({this.onChanged, this.disabled = false, this.width = 180, this.height = 45, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: InkWell(
        onTap: () {
          if (!disabled) {
            onChanged();
          }
        },
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: disabled ? Colors.grey : Colors.orangeAccent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: disabled ? Colors.grey : Colors.orangeAccent,
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 0)
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).primaryColor,
                ),
                Expanded(child: const SizedBox()),
                Text(
                  text,
                  style: Theme.of(context).textTheme.headline2.apply(color: Theme.of(context).primaryColor),
                ),
                Expanded(child: const SizedBox()),
              ],
            )
        ),
      ),
    );
  }
}