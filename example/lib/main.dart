import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:intlphonenumberinputtest/text_styles.resource.dart';

import 'colors.resource.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var darkTheme = ThemeData.dark().copyWith(primaryColor: Colors.blue);

    return MaterialApp(
      title: 'Demo',
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(title: Text('Demo')),
          body: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'NG';
  PhoneNumber number = PhoneNumber(isoCode: 'NG');

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStylesResource.sourceSansWeight400.copyWith(
      color: ColorsResource.mainBlack,
      fontSize: 17.0,
    );

    final inputDecoration = decoration(
      label: "number",
      icon: Container(
        color: Colors.blue,
        height: 16,
        width: 16,
      ),
    );

    return Form(
      key: formKey,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InternationalPhoneNumberInput(
              initialValue: number,
              searchBoxDecoration: decoration(
                label: "country",
                mainBorderColor: ColorsResource.mainBlack,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shouldValidate: false,
              ),
              onInputValidated: (bool value) {
                print(value);
              },
              validator: _validator,
              formatInput: false,
              ignoreBlank: true,
              cursorColor: ColorsResource.black,
              selectorConfig: const SelectorConfig(
                setSelectorButtonAsPrefixIcon: true,
                trailingSpace: false,
                leadingPadding: 20,
              ),
              autoValidateMode: AutovalidateMode.onUserInteraction,
              selectorTextStyle: textStyle,
              textStyle: textStyle,
              inputDecoration: inputDecoration,
              onInputChanged: (phone) {},
              onCountryLoaded: (country) {},
            ),
            ElevatedButton(
              onPressed: () {
                formKey.currentState?.validate();
              },
              child: Text('Validate'),
            ),
            ElevatedButton(
              onPressed: () {
                getPhoneNumber('+15417543010');
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                formKey.currentState?.save();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validator(String? inputValue) {
    return "errror";
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

    setState(() {
      this.number = number;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

InputDecoration decoration({
  String? label,
  Widget? icon,
  EdgeInsets? padding,
  bool shouldValidate = true,
  Color mainBorderColor = ColorsResource.mainWhite,
  Color? fillColor,
  double radius = 100.0,
}) =>
    InputDecoration(
      contentPadding: padding ??
          const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 16,
          ),
      isCollapsed: true,
      isDense: true,
      hintText: label,
      hintStyle: TextStylesResource.sourceSansWeight400.copyWith(
        color: ColorsResource.mainBlack,
        fontSize: 17.0,
      ),
      filled: fillColor != null,
      fillColor: fillColor,
      helperText: shouldValidate ? '' : null,
      helperStyle: shouldValidate
          ? TextStylesResource.sourceSansWeight400.copyWith(
              color: ColorsResource.mainWhite,
              fontSize: 9,
            )
          : null,
      suffixIcon: icon != null
          ? Container(
              margin: const EdgeInsets.only(right: 18),
              child: icon,
            )
          : null,
      suffixIconConstraints: icon != null
          ? const BoxConstraints(
              minHeight: 20,
              minWidth: 20,
            )
          : null,
      errorStyle: TextStylesResource.sourceSansWeight400.copyWith(
        color: ColorsResource.mainWhite,
        fontSize: 9,
      ),
      counterStyle: TextStylesResource.sourceSansWeight400.copyWith(
        color: Colors.transparent,
        fontSize: 9,
      ),
      focusedBorder: _inputBorder(color: mainBorderColor, radius: radius),
      enabledBorder: _inputBorder(color: mainBorderColor, radius: radius),
      errorBorder:
          _inputBorder(color: mainBorderColor, radius: radius),
      focusedErrorBorder:
          _inputBorder(color: mainBorderColor, radius: radius),
    );

InputBorder _inputBorder({
  Color color = ColorsResource.mainBlack,
  required double radius,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(
      color: color,
      width: 1,
    ),
  );
}
