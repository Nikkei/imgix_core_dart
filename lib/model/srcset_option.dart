import 'package:imgix_core_dart/constants.dart' as constants;
import 'package:imgix_core_dart/validators.dart';

class SrcsetOption {
  SrcsetOption(
      {this.minWidth = constants.DEFAULT_MIN_WIDTH,
      this.maxWidth = constants.DEFAULT_MAX_WIDTH,
      this.tolerance = constants.SRCSET_DEFAULT_TOLERANCE,
      this.enableVariableQuality = false}) {
    if (!isValidRange(minWidth, maxWidth)) {
      throw const FormatException(
          'The min and max srcset widths can only be passed positive Number values');
    }
    if (!isValidWidthTolerance(tolerance)) {
      throw Exception(
          'The srcset widthTolerance argument can only be passed a positive scalar number');
    }
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'minWidth': minWidth,
        'maxWidth': maxWidth,
        'widthTolerance': tolerance,
        'variableQuality': enableVariableQuality
      };

  final int minWidth, maxWidth;
  final double tolerance;
  final bool enableVariableQuality;
}
