import 'package:flutter/material.dart';
import 'package:frank/ui/resources/assets_funny_texts.dart';
import 'package:frank/ui/resources/assets_images.dart';
import 'package:frank/ui/resources/colors.resource.dart';
import 'package:frank/ui/resources/gradients/gradients.dart';
import 'package:frank/ui/resources/text_styles.resource.dart';
import 'package:frank/ui/widgets/animated_gesture_detector.dart';
import 'package:frank/ui/widgets/phone_input/src/models/country_model.dart';
import 'package:frank/ui/widgets/phone_input/src/utils/util.dart';
import 'package:frank/ui/widgets/phone_input/src/widgets/item.dart';

/// Creates a list of Countries with a search textfield.
class CountrySearchListWidget extends StatefulWidget {
  final List<Country> countries;
  final InputDecoration? searchBoxDecoration;
  final String? locale;
  final ScrollController? scrollController;
  final bool autoFocus;

  const CountrySearchListWidget(
    this.countries,
    this.locale, {
    Key? key,
    this.searchBoxDecoration,
    this.scrollController,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  _CountrySearchListWidgetState createState() =>
      _CountrySearchListWidgetState();
}

class _CountrySearchListWidgetState extends State<CountrySearchListWidget> {
  late final TextEditingController _searchController = TextEditingController();
  late List<Country> filteredCountries;

  @override
  void initState() {
    final value = _searchController.text.trim();
    filteredCountries = Utils.filterCountries(
      countries: widget.countries,
      locale: widget.locale,
      value: value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 50),
        Image.asset(
          AssetFunnyTexts.countryCode,
          color: ColorsResource.mainBlack,
          width: 155,
          height: 25,
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38),
          child: TextFormField(
            decoration: widget.searchBoxDecoration,
            controller: _searchController,
            onChanged: (value) {
              final value = _searchController.text.trim();
              return setState(
                () => filteredCountries = Utils.filterCountries(
                  countries: widget.countries,
                  locale: widget.locale,
                  value: value,
                ),
              );
            },
          ),
        ),
        Flexible(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ListView.builder(
                controller: widget.scrollController,
                itemCount: filteredCountries.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0 || index == filteredCountries.length + 1) {
                    return const SizedBox(height: 12);
                  }

                  final country = filteredCountries[index - 1];

                  return DirectionalCountryListTile(
                    country: country,
                    locale: widget.locale,
                  );
                },
              ),
              Container(
                height: 30,
                decoration: BoxDecoration(
                    gradient: baseGradient(
                  colors: [
                    ColorsResource.mainWhite,
                    ColorsResource.mainWhite,
                    ColorsResource.mainWhite.withOpacity(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}

class DirectionalCountryListTile extends StatelessWidget {
  final Country country;
  final String? locale;

  const DirectionalCountryListTile({
    Key? key,
    required this.country,
    required this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedGestureDetector(
      onTap: () => Navigator.of(context).pop(country),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 49,
          top: 10,
          bottom: 10,
        ),
        child: Row(
          children: [
            Flag(country: country),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Utils.getCountryName(country, locale)}',
                  textDirection: Directionality.of(context),
                  textAlign: TextAlign.start,
                  style: TextStylesResource.quincyWeight400.copyWith(
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${country.dialCode ?? ''}',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  style: TextStylesResource.quincyWeight400.copyWith(
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
