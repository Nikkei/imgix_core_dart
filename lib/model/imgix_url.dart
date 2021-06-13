import 'package:imgix_core_dart/encoding.dart';
import 'package:meta/meta.dart';
import 'package:imgix_core_dart/constants.dart' as constants;
import 'package:imgix_core_dart/validators.dart' as validators;
/// wip
class ImgixURL {
  ImgixURL(String path, this.domain,
      {this.params, bool useHttps = true, this.includeLibParam = false})
      : _useHttps = useHttps,
        sanitizedPath = path.sanitizedPath {
    final isValidDomain = validators.validateDomain(domain);
    if (!isValidDomain) {
      throw const FormatException(
          'Domain must be passed in as fully-qualified domain name '
          'and should not include a protocol or any path element, '
          'i.e. "example.imgix.net".');
    }
    params = {
      if (params != null) ...params!,
      if (includeLibParam) ...constants.metaParams
    };
  }

  factory ImgixURL.http(String path, String domain,
          {Map<String, String>? params, bool? includeLibParam}) =>
      ImgixURL(path, domain,
          useHttps: false,
          includeLibParam: includeLibParam ?? false,
          params: params);

  factory ImgixURL.https(String path, String domain,
          {Map<String, String>? params, bool? includeLibParam}) =>
      ImgixURL(path, domain,
          useHttps: true,
          includeLibParam: includeLibParam ?? false,
          params: params);

  factory ImgixURL.withLibParam(String path, String domain,
          {Map<String, String>? params, bool useHttps = true}) =>
      ImgixURL(path, domain,
          params: params, useHttps: useHttps, includeLibParam: true);

  final String sanitizedPath;
  final bool _useHttps;
  String domain;

  Map<String, String>? params;
  final bool includeLibParam;

  @override
  String toString() {
    return 'wip';
  }

  ImgixURL copyWith(
      {String? path,
      String? domain,
      Map<String, String>? params,
      bool? useHttps,
      bool? includeLibParam}) {
    return ImgixURL(path ?? sanitizedPath, domain ?? this.domain,
        params: params ?? this.params,
        includeLibParam: includeLibParam ?? this.includeLibParam,
        useHttps: useHttps ?? _useHttps);
  }

  Uri get asUri => Uri(
      scheme: scheme,
      host: domain,
      path: sanitizedPath,
      queryParameters: params);

  String get scheme => _useHttps ? 'https' : 'http';

  @visibleForTesting
  String buildParams(Map<String, String> params) {
    final queryParams = <String>[];

    for (final key in params.keys) {
      final val = params[key]!;
      final encodedKey = key.inUriEncodeComponent;
      final encodedVal =
          key.isBase64 ? val.inBase64Encoding : val.inUriEncodeComponent;
      queryParams.add('$encodedKey=$encodedVal');
    }
    return queryParams.join('&');
  }
}
