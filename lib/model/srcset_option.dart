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
      throw const FormatException(
          'The srcset widthTolerance argument can only be passed a positive scalar number');
    }
  }

  const SrcsetOption.base()
      : maxWidth = constants.DEFAULT_MAX_WIDTH,
        minWidth = constants.DEFAULT_MIN_WIDTH,
        tolerance = constants.SRCSET_DEFAULT_TOLERANCE,
        enableVariableQuality = true;

  /// [generateTargetWidths] creates an array of integer image widths.
  /// The image widths begin at the [minWidth] value and end at the
  /// [maxWidth] value––with a defaultTolerance amount of tolerable image
  /// width-variance between them.
  List<int> generateTargetWidths() {
    if (_isNotCustom()) {
      return constants.DEFAULT_WIDTHS.toList();
    }
    final resolutions = <int>[];
    final incrementPercentage = tolerance;
    var prev = minWidth.toDouble();

    int ensureEven(double n) {
      return 2 * (n / 2).round();
    }

    while (prev < (maxWidth.toDouble())) {
      resolutions.add(ensureEven(prev));
      prev *= 1 + (incrementPercentage * 2);
    }
    return resolutions;
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

  bool _isNotCustom() {
    return minWidth == constants.DEFAULT_MIN_WIDTH &&
        maxWidth == constants.DEFAULT_MAX_WIDTH &&
        tolerance == constants.SRCSET_DEFAULT_TOLERANCE;
  }
}
