import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs
/// App text styles
class TextStylesResource {
  /// Fonts
  static const sourceSans = TextStyle(fontFamily: 'SourceSansPro');
  static const quincy = TextStyle(fontFamily: 'QuincyCF');

  /// Weight
  static final sourceSansWeight700 = sourceSans.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final sourceSansWeight600 = sourceSans.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final sourceSansWeight400 = sourceSans.copyWith(
    fontWeight: FontWeight.w400,
  );
  static final quincyWeight700 = quincy.copyWith(
    fontWeight: FontWeight.w700,
  );
  static final quincyWeight400 = quincy.copyWith(
    fontWeight: FontWeight.w400,
  );
}
