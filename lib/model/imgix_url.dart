import 'package:meta/meta.dart';
import 'package:imgix_core_dart/constants.dart' as constants;

class ImgixURL {
  ImgixURL(String path, this.domain,
      {this.params, bool useHttps = true, this.includeLibParam = false})
      : _useHttps = useHttps,
        sanitizedPath = sanitizePath(path) {
    final isValidDomain =
        RegExp(constants.DOMAIN_REGEX, caseSensitive: false, multiLine: false)
            .hasMatch(domain);
    if (!isValidDomain) {
      throw const FormatException(
          'Domain must be passed in as fully-qualified domain name and should not include a protocol or any path element, i.e. "example.imgix.net".');
    }
    if (includeLibParam) {
      params = {
        if (params != null) ...params!,
        'ixlib': 'dart-${constants.IMGIX_LIB_VERSION}'
      };
    }
  }

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
    return '';
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

  Uri get asUri => Uri(scheme: scheme, host: domain, path: sanitizedPath);

  String get scheme => _useHttps ? 'https' : 'http';

  @visibleForTesting
  static String sanitizePath(String path) {
    path = path.replaceFirst(RegExp(r'^\/'), '');

    if (RegExp(r'^https?:\/\/').hasMatch(path)) {
      path = Uri.encodeComponent(path);
    } else {
      path = Uri.encodeFull(path)
          .replaceAll('#', '%23')
          .replaceAll('?', '%3F')
          .replaceAll(':', '%3A');
    }

    return '/' + path;
  }
}
