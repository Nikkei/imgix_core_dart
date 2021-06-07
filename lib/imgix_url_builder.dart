import 'dart:core';
import 'package:imgix_core_dart/encoding.dart';
import 'package:imgix_core_dart/constants.dart' as constants;
import 'package:imgix_core_dart/validators.dart' as validators;
import 'package:meta/meta.dart';

/// [ImgixURLBuilder] facilitates the building of imgix URLs.
///
/// params
/// - [domain] : Domain of urls to be generated.
/// - [shouldUseHttpsByDefault] : If true,generated urls start with "https" prefix. Otherwise, "http".
/// - [defaultSignKey] : Key to sign generated url.
/// - [includeLibParam] : If true, generated Urls contain libParam. LibParam is "dart-$[IMGIX_LIB_VERSION]"
class ImgixURLBuilder {
  ImgixURLBuilder(
      {required String domain,
      bool shouldUseHttpsByDefault = true,
      String? defaultSignKey,
      bool includeLibParam = false})
      : _domain = domain,
        _useHttpsByDefault = shouldUseHttpsByDefault,
        _signKey = defaultSignKey,
        _shouldIncludeLibParamByDefault = includeLibParam {
    final isValidDomain = validators.validateDomain(_domain);
    assert(isValidDomain,
        'Domain must not be empty and must be passed in as fully-qualified domain name and should not include a protocol or any path element, i.e. "example.imgix.net".');
  }

  /// A source's domain, i.e. example.imgix.net
  final String _domain;

  /// Denotes whether or not to use HTTPS. Default is true.
  bool _useHttpsByDefault;

  /// A source's secure token used to sign/secure URLs.
  String? _signKey;

  /// Denotes whether or not to apply the ixLibVersion. Default is false.
  bool _shouldIncludeLibParamByDefault;

  /// [setDefaultUseHttpsStatus] sets a builder's [_useHttpsByDefault] field to true or false.
  ///
  /// Setting [_useHttpsByDefault] to false forces the builder to use HTTP.
  void setDefaultUseHttpsStatus(bool useHttps) {
    _useHttpsByDefault = _useHttpsByDefault;
  }

  void setDefaultSignKey(String signKey) {
    _signKey = signKey;
  }

  /// [setDefaultIncludeLibParamStatus] toggles the [_shouldIncludeLibParamByDefault] on and off.
  ///
  /// If [_shouldIncludeLibParamByDefault] is set to
  /// true, the ixlib param will be toggled on.
  ///
  /// Otherwise, if [_shouldIncludeLibParamByDefault] is set to
  /// false, the ixlib param will be toggled off and will not appear in the final URL.
  void setDefaultIncludeLibParamStatus(bool useLibParam) {
    _shouldIncludeLibParamByDefault = useLibParam;
  }

  /// [_scheme] gets the URL scheme to use, either "http" or "https"
  /// (the scheme uses HTTPS by default).
  String _scheme() {
    if (_useHttpsByDefault) {
      return 'https';
    } else {
      return 'http';
    }
  }

  /// [_urlPrefix] gets the URL prefix to use, either "http://" or "https://"
  /// (the scheme uses HTTPS by default).
  String _urlPrefix() {
    return _scheme() + '://';
  }

  Uri createURL(String path) {
    return Uri.parse(createPlainURLString(path));
  }

  /// [createPlainURLString] generates imgix url with default options.
  ///
  /// i.e. `createPlainURLString(/foo/bar/buzz)` returns 'https://example.com/foo/bar/buzz'
  String createPlainURLString(String path) {
    return createURLString(path);
  }

  /// [createURLString] creates imgix url with options
  String createURLString(String path,
      {Map<String, String>? params,
      bool? useHttps,
      bool? includeLibraryParams}) {
    path = path.sanitizedPath;
    params ??= <String, String>{};
    params = _joinWithMetaParams(params, includeLibParam: includeLibraryParams);
    var queryParams = buildParams(params);
    if (_signKey?.isNotEmpty ?? false) {
      queryParams = signParams(path, queryParams, _signKey!);
    }
    final delimiter = params.isEmpty ? '' : '?';
    if (useHttps == null) {
      return _urlPrefix() + _domain + path + delimiter + queryParams;
    } else {
      final urlPrefix = useHttps ? 'https://' : 'http://';
      return urlPrefix + _domain + path + delimiter + queryParams;
    }
  }

  /// [buildParams] uri-encodes query parameter keys and values, and then concatenates them into String with delimiter '&'.
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

  Map<String, String> _joinWithMetaParams(Map<String, String> queryParams,
      {bool? includeLibParam}) {
    return {
      ...queryParams,
      if (includeLibParam ?? _shouldIncludeLibParamByDefault) ...constants.metaParams
    };
  }

  @visibleForTesting

  /// [signParams] adds md5 signature to query parameter.
  String signParams(String path, String queryParams, String signKey) {
    final signature = createSignature(signKey, path, queryParams);
    if (queryParams.isNotEmpty) {
      return queryParams = queryParams + '&s=' + signature;
    } else {
      return queryParams = '?s=' + signature;
    }
  }
}
