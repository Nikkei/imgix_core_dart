import 'package:imgix_core_dart/constants.dart' as constants;
bool validateDomain(String domain)=>domain.isNotEmpty & RegExp(constants.DOMAIN_REGEX).hasMatch(domain);