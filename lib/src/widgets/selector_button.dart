import 'package:flutter/material.dart';
import 'package:frank/ui/resources/colors.resource.dart';
import 'package:frank/ui/widgets/phone_input/src/models/country_model.dart';
import 'package:frank/ui/widgets/phone_input/src/utils/selector_config.dart';
import 'package:frank/ui/widgets/phone_input/src/widgets/countries_search_list_widget.dart';
import 'package:frank/ui/widgets/phone_input/src/widgets/item.dart';

/// [SelectorButton]
class SelectorButton extends StatelessWidget {
  final List<Country> countries;
  final Country? country;
  final SelectorConfig selectorConfig;
  final TextStyle? selectorTextStyle;
  final InputDecoration? searchBoxDecoration;
  final bool autoFocusSearchField;
  final String? locale;
  final bool isEnabled;
  final bool isScrollControlled;

  final ValueChanged<Country?> onCountryChanged;

  const SelectorButton({
    Key? key,
    required this.countries,
    required this.country,
    required this.selectorConfig,
    required this.selectorTextStyle,
    required this.searchBoxDecoration,
    required this.autoFocusSearchField,
    required this.locale,
    required this.onCountryChanged,
    required this.isEnabled,
    required this.isScrollControlled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final onTap = countries.isNotEmpty && countries.length > 1 && isEnabled
        ? () async {
            final selected =
                await showCountrySelectorBottomSheet(context, countries);

            if (selected != null) {
              onCountryChanged(selected);
            }
          }
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Item(
          country: country,
          leadingPadding: selectorConfig.leadingPadding,
          trailingSpace: selectorConfig.trailingSpace,
          textStyle: selectorTextStyle,
          onTap: onTap,
        ),
      ),
    );
  }

  Future<Country?> showCountrySelectorBottomSheet(
      BuildContext inheritedContext, List<Country> countries) {
    return showModalBottomSheet(
      context: inheritedContext,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
            ),
            DraggableScrollableSheet(
              minChildSize: .8,
              maxChildSize: 1,
              initialChildSize: .8,
              builder: (context, controller) {
                return Container(
                  decoration: const ShapeDecoration(
                    color: ColorsResource.mainWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                  child: CountrySearchListWidget(
                    countries,
                    locale,
                    searchBoxDecoration: searchBoxDecoration,
                    scrollController: controller,
                    autoFocus: autoFocusSearchField,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
