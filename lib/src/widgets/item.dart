import 'package:flutter/material.dart';
import 'package:animated_gesture_detector/animated_gesture_detector.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';

class Item extends StatelessWidget {
  final Country? country;
  final TextStyle? textStyle;
  final double? leadingPadding;
  final bool trailingSpace;
  final VoidCallback? onTap;

  const Item({
    Key? key,
    this.country,
    this.textStyle,
    this.leadingPadding = 12,
    this.trailingSpace = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dialCode = country?.dialCode ?? '';
    if (trailingSpace) {
      dialCode = dialCode.padRight(5, '   ');
    }
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: leadingPadding),
          AnimatedGestureDetector(
            onTap: onTap,
            child: Flag(country: country),
          ),
          const SizedBox(width: 6.0),
          Text(
            dialCode,
            textDirection: TextDirection.ltr,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}

class Flag extends StatelessWidget {
  final Country? country;

  const Flag({Key? key, this.country}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return country != null
        ? Container(
            clipBehavior: Clip.hardEdge,
            height: 22,
            width: 30,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Image.asset(
              country!.flagUri,
              fit: BoxFit.cover,
            ),
          )
        : const SizedBox.shrink();
  }
}
