import 'package:imgix_core_dart/constants.dart' as constants;

bool validateDomain(String domain) =>
    domain.isNotEmpty & RegExp(constants.DOMAIN_REGEX).hasMatch(domain);

bool isValidRange(int min, int max) {
  return !(min < 0 || max < 0) & (min < max);
}

bool isValidWidthTolerance(double widthTolerance) {
  return widthTolerance >= 0;
}

bool isValidWidths(List<int>? customWidths) {
  return customWidths != null && customWidths.isNotEmpty && !customWidths.any((e)=>e<0);
}
