import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/providers/country_provider.dart';
import 'package:intl_phone_number_input/src/utils/phone_number.dart';
import 'package:intl_phone_number_input/src/utils/phone_number/phone_number_util.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/util.dart';
import 'package:intl_phone_number_input/src/utils/widget_view.dart';
import 'package:intl_phone_number_input/src/widgets/animated_gradient.dart';
import 'package:intl_phone_number_input/src/widgets/rx_builder.dart';
import 'package:intl_phone_number_input/src/widgets/selector_button.dart';
import 'package:intl_phone_number_input/src/widgets/text_styles.resource.dart';
import 'package:rxdart/rxdart.dart';

/// A [TextFormField] for [InternationalPhoneNumberInput].
///
/// [initialValue] accepts a [PhoneNumber] this is used to set initial values
/// for phone the input field and the selector button
///
/// [selectorButtonOnErrorPadding] is a double which is used to align the selector
/// button with the input field when an error occurs
///
/// [locale] accepts a country locale which will be used to translation, if the
/// translation exist
///
/// [countries] accepts list of string on Country isoCode, if specified filters
/// available countries to match the [countries] specified.
class InternationalPhoneNumberInput extends StatefulWidget {
  const InternationalPhoneNumberInput({
    Key? key,
    this.selectorConfig = const SelectorConfig(),
    required this.onInputChanged,
    this.onInputValidated,
    this.onSubmit,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.textFieldController,
    this.keyboardAction,
    this.initialValue,
    this.hintText = 'Phone number',
    this.errorMessage = 'Invalid phone number',
    this.selectorButtonOnErrorPadding = 24,
    this.spaceBetweenSelectorAndTextField = 12,
    this.maxLength = 15,
    this.isEnabled = true,
    this.formatInput = true,
    this.autoFocus = false,
    this.autoFocusSearch = false,
    this.autoValidateMode = AutovalidateMode.disabled,
    this.ignoreBlank = false,
    this.countrySelectorScrollControlled = true,
    this.locale,
    this.textStyle,
    this.selectorTextStyle,
    this.inputBorder,
    required this.inputDecoration,
    this.searchBoxDecoration,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.focusNode,
    this.cursorColor,
    this.autofillHints,
    this.countries,
    required this.onCountryLoaded,
    this.additionalErrorStream,
  }) : super(key: key);

  final SelectorConfig selectorConfig;

  final Function(PhoneNumber)? onInputChanged;
  final ValueChanged<bool>? onInputValidated;

  final VoidCallback? onSubmit;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final ValueChanged<PhoneNumber>? onSaved;

  final TextEditingController? textFieldController;
  final TextInputAction? keyboardAction;

  final PhoneNumber? initialValue;
  final String? hintText;
  final String? errorMessage;

  final double selectorButtonOnErrorPadding;

  /// Ignored if [setSelectorButtonAsPrefixIcon = true]
  final double spaceBetweenSelectorAndTextField;
  final int maxLength;

  final bool isEnabled;
  final bool formatInput;
  final bool autoFocus;
  final bool autoFocusSearch;
  final AutovalidateMode autoValidateMode;
  final bool ignoreBlank;
  final bool countrySelectorScrollControlled;

  final String? locale;

  final TextStyle? textStyle;
  final TextStyle? selectorTextStyle;
  final InputBorder? inputBorder;
  final InputDecoration inputDecoration;
  final InputDecoration? searchBoxDecoration;
  final Color? cursorColor;
  final TextAlign textAlign;
  final TextAlignVertical textAlignVertical;
  final EdgeInsets scrollPadding;

  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;

  final List<String>? countries;

  final Function(Country?) onCountryLoaded;

  final ValueStream<String?>? additionalErrorStream;

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InternationalPhoneNumberInput> {
  TextEditingController? controller;
  double selectorButtonBottomPadding = 0;

  Country? country;
  List<Country> countries = [];
  bool isNotValid = true;

  String errorMessage = '';

  final _errorSubject = BehaviorSubject<String?>.seeded(null);
  late final ValueStream<String?> _errorStream = _errorSubject;

  @override
  void dispose() {
    _errorSubject.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadCountries();
    controller = widget.textFieldController ?? TextEditingController();
    initWidget();
  }

  @override
  Widget build(BuildContext context) {
    return _InputWidgetView(
      state: this,
    );
  }

  @override
  void didUpdateWidget(InternationalPhoneNumberInput oldWidget) {
    loadCountries(previouslySelectedCountry: country);
    if (oldWidget.initialValue?.hash != widget.initialValue?.hash) {
      if (country!.alpha2Code != widget.initialValue?.isoCode) {
        loadCountries();
      }
      initWidget();
    }
    super.didUpdateWidget(oldWidget);
  }

  /// [initWidget] sets initial values of the widget
  Future<void> initWidget() async {
    if (widget.initialValue != null) {
      if (widget.initialValue!.phoneNumber != null &&
          widget.initialValue!.phoneNumber!.isNotEmpty &&
          (await PhoneNumberUtil.isValidNumber(
              phoneNumber: widget.initialValue!.phoneNumber!,
              isoCode: widget.initialValue!.isoCode!))!) {
        final phoneNumber =
            await PhoneNumber.getParsableNumber(widget.initialValue!);

        controller!.text = widget.formatInput
            ? phoneNumber
            : phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

        phoneNumberControllerListener();
      }
    }
  }

  void loadCountries({Country? previouslySelectedCountry}) {
    if (mounted) {
      var countries =
          CountryProvider.getCountriesData(countries: widget.countries);

      final country = previouslySelectedCountry ??
          Utils.getInitialSelectedCountry(
            countries,
            widget.initialValue?.isoCode ?? '',
          );

      // Remove potential duplicates
      countries = countries.toSet().toList();

      final countryComparator = widget.selectorConfig.countryComparator;
      if (countryComparator != null) {
        countries.sort(countryComparator);
      }

      setState(() {
        this.countries = countries;
        this.country = country;
        widget.onCountryLoaded(country);
      });
    }
  }

  void phoneNumberControllerListener() {
    if (mounted) {
      final parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      getParsedPhoneNumber(parsedPhoneNumberString, country?.alpha2Code)
          .then((phoneNumber) {
        if (phoneNumber == null) {
          final phoneNumber = '${country?.dialCode}$parsedPhoneNumberString';

          if (widget.onInputChanged != null) {
            widget.onInputChanged!(PhoneNumber(
                phoneNumber: phoneNumber,
                isoCode: country?.alpha2Code,
                dialCode: country?.dialCode));
          }

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(false);
          }
          isNotValid = true;
        } else {
          if (widget.onInputChanged != null) {
            widget.onInputChanged!(PhoneNumber(
                phoneNumber: phoneNumber,
                isoCode: country?.alpha2Code,
                dialCode: country?.dialCode));
          }

          if (widget.onInputValidated != null) {
            widget.onInputValidated!(true);
          }
          isNotValid = false;
        }
      });
    }
  }

  /// Returns a formatted String of [phoneNumber] with [isoCode], returns `null`
  /// if [phoneNumber] is not valid or if an [Exception] is caught.
  Future<String?> getParsedPhoneNumber(
      String phoneNumber, String? isoCode) async {
    if (phoneNumber.isNotEmpty && isoCode != null) {
      try {
        final isValidPhoneNumber = await PhoneNumberUtil.isValidNumber(
            phoneNumber: phoneNumber, isoCode: isoCode);

        if (isValidPhoneNumber!) {
          return await PhoneNumberUtil.normalizePhoneNumber(
              phoneNumber: phoneNumber, isoCode: isoCode);
        }
      } on Exception {
        return null;
      }
    }
    return null;
  }

  /// Creates or Select [InputDecoration]
  InputDecoration getInputDecoration(InputDecoration decoration) {
    return decoration.copyWith(
      prefixIcon: SelectorButton(
        country: country,
        countries: countries,
        onCountryChanged: onCountryChanged,
        selectorConfig: widget.selectorConfig,
        selectorTextStyle: widget.selectorTextStyle,
        searchBoxDecoration: widget.searchBoxDecoration,
        locale: locale,
        isEnabled: widget.isEnabled,
        autoFocusSearchField: widget.autoFocusSearch,
        isScrollControlled: widget.countrySelectorScrollControlled,
      ),
    );
  }

  /// Validate the phone number when a change occurs
  void onChanged(String value) {
    phoneNumberControllerListener();
  }

  /// Changes Selector Button Country and Validate Change.
  void onCountryChanged(Country? country) {
    setState(() {
      this.country = country;
      widget.onCountryLoaded(country);
    });
    phoneNumberControllerListener();
  }

  void _phoneNumberSaved() {
    if (mounted) {
      final parsedPhoneNumberString =
          controller!.text.replaceAll(RegExp(r'[^\d+]'), '');

      final phoneNumber =
          '${country?.dialCode ?? ''}' + parsedPhoneNumberString;

      widget.onSaved?.call(
        PhoneNumber(
            phoneNumber: phoneNumber,
            isoCode: country?.alpha2Code,
            dialCode: country?.dialCode),
      );
    }
  }

  /// Saved the phone number when form is saved
  void onSaved(String? value) {
    _phoneNumberSaved();
  }

  /// Corrects duplicate locale
  String? get locale {
    if (widget.locale == null) return null;

    if (widget.locale!.toLowerCase() == 'nb' ||
        widget.locale!.toLowerCase() == 'nn') {
      return 'no';
    }
    return widget.locale;
  }
}

class _InputWidgetView
    extends WidgetView<InternationalPhoneNumberInput, _InputWidgetState> {
  final _InputWidgetState state;

  _InputWidgetView({Key? key, required this.state})
      : super(key: key, state: state);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedGradient(
          colors: const [
            Color(0xFFC200BB),
            Color(0xFF204FF6),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.0,
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: state
                            .getInputDecoration(widget.inputDecoration)
                            .contentPadding,
                      ),
                    ),
                  ),
                ),
              ),
              _errorMessage(),
            ],
          ),
        ),
        Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            errorColor: Colors.transparent,
          ),
          child: TextFormField(
            controller: state.controller,
            cursorColor: widget.cursorColor,
            focusNode: widget.focusNode,
            enabled: widget.isEnabled,
            autofocus: widget.autoFocus,
            keyboardType: TextInputType.number,
            textInputAction: widget.keyboardAction,
            style: widget.textStyle,
            decoration:
                state.getInputDecoration(widget.inputDecoration).copyWith(
                      focusedBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            onEditingComplete: widget.onSubmit,
            onFieldSubmitted: widget.onFieldSubmitted,
            autovalidateMode: widget.autoValidateMode,
            autofillHints: widget.autofillHints,
            validator: widget.validator,
            onSaved: state.onSaved,
            maxLength: widget.maxLength,
            scrollPadding: widget.scrollPadding,
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.maxLength),
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: state.onChanged,
          ),
        ),
      ],
    );
  }

  Widget _errorMessage() {
    return RxBuilder<String?>(
      stream: widget.additionalErrorStream,
      builder: (context, sError) {
        final error = sError.data;

        return RxBuilder<String?>(
          stream: state._errorStream,
          builder: (context, sError) {
            state.errorMessage = error ?? sError.data ?? state.errorMessage;
            return AnimatedOpacity(
              duration: Duration(milliseconds: 150),
              opacity: (error ?? sError.data) != null ? 1 : 0,
              child: Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 20, top: 3),
                child: Text(
                  state.errorMessage,
                  style: TextStylesResource.sourceSansWeight400.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
