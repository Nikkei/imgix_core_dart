library imgix_core_dart;
import 'dart:convert';

import 'package:imgix_core_dart/encoding.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// [ImgixClient] is a client for imgix and helps developers generate imgix url.
class ImgixClient {
  ImgixClient({
    required this.domain,
    this.useHTTPS = true,
    this.includeLibraryParam = true,
    this.secureURLToken,
  }) {
    if (!_domainRegex.hasMatch(domain)) {
      throw Exception(
          'Domain must be passed in as fully-qualified domain name and should not include a protocol or any path element, i.e. "example.imgix.net".');
    }

    if (includeLibraryParam) {
      libraryParam = 'dart-' + VERSION;
    }

    urlPrefix = useHTTPS ? 'https://' : 'http://';
  }

  /// version of package useful to identify client library version from logs.
  static const VERSION = '1.0.0';

  static final _domainRegex = RegExp(
      r'^(?:[a-z\d\-_]{1,62}\.){0,125}(?:[a-z\d](?:\-(?=\-*[a-z\d])|[a-z]|\d){0,62}\.)[a-z\d]{1,63}$',
      caseSensitive: false,
      multiLine: false);
  static const _minSrcsetWidth = 100.0;
  static const _maxSrcsetWidth = 8192.0;
  static const _defaultSrcsetWidthTolerance = .08;
  static final _defaultSrcsetWidths = _generateTargetWidths(
      _defaultSrcsetWidthTolerance, _minSrcsetWidth, _maxSrcsetWidth);

  // returns an array of width values used during scrset generation
  static List<int> _generateTargetWidths(
    double widthTolerance,
    double minWidth,
    double maxWidth,
  ) {
    final resolutions = <int>[];
    final incrementPercentage = widthTolerance;
    minWidth = minWidth.floor() as double;
    maxWidth = maxWidth.floor() as double;

    int ensureEven(double n) {
      return 2 * (n / 2).floor();
    }

    var prev = minWidth;

    while (prev < maxWidth) {
      resolutions.add(ensureEven(prev));
      prev *= 1 + (incrementPercentage * 2);
    }

    return resolutions;
  }

  static final _dprQualities = {
    1: 75,
    2: 50,
    3: 35,
    4: 23,
    5: 20,
  };

  /// - [domain]  must be passed in as fully-qualified domain name and should not include a protocol or any path element.
  final String domain;

  /// [useHTTPS] defines url scheme. If true url starts with `https://` else `http://`.
  final bool useHTTPS;

  /// If true, generated url will contain `ixlib=dart-$VERSION` as a query parameter.
  final bool includeLibraryParam;

  /// If [secureURLToken] is provided, generated url will have md5 signature as a query parameter.
  final String? secureURLToken;

  /// If [includeLibraryParam] is true, libraryParam is `dart-$VERSION` else null.
  String? libraryParam;

  /// Scheme for generated url. `https://` or `http://`.
  late String urlPrefix;

  /// [buildURL] returns image url string with query parameters.
  /// About the parameters, see https://docs.imgix.com/apis/rendering
  String buildURL(String path, [Map<String, dynamic>? params]) {
    params ??= <String, dynamic>{};

    path = sanitizePath(path);

    var queryParams = buildParams(params);
    if (secureURLToken != null) {
      queryParams = signParams(path, queryParams);
    }

    return urlPrefix + domain + path + queryParams;
  }

  @visibleForTesting
  String sanitizePath(String path) {
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

  @visibleForTesting
  String buildParams(Map<String, dynamic> params) {
    if (libraryParam != null) {
      params['ixlib'] = libraryParam;
    }

    final queryParams = <String>[];

    for (final key in params.keys) {
      final dynamic val = params[key];
      final encodedKey = Uri.encodeComponent(key);
      String encodedVal;

      if (key.isBase64) {
        encodedVal = base64UrlEncode(utf8.encode(val));

        // see: https://docs.imgix.com/apis/url
        // > Please keep in mind that this uses the URL-safe alphabet as
        // > defined in RFC 4648, and that any padding characters (=) must be
        // > omitted from the final encoded value.
        encodedVal = encodedVal.replaceAll('=', '');
      } else {
        encodedVal = Uri.encodeComponent(val.toString());
      }
      queryParams.add('$encodedKey=$encodedVal');
    }

    if (queryParams.isNotEmpty) {
      queryParams[0] = '?' + queryParams[0];
    }

    return queryParams.join('&');
  }

  @visibleForTesting

  /// [signParams] adds md5 signature to query parameter.
  String signParams(String path, String queryParams) {
    final signatureBase = secureURLToken! + path + queryParams;
    final signature = md5.convert(utf8.encode(signatureBase)).toString();

    if (queryParams.isNotEmpty) {
      return queryParams = queryParams + '&s=' + signature;
    } else {
      return queryParams = '?s=' + signature;
    }
  }

  String buildSrcSet(
    String path, [
    Map<String, String> params = const {},
    Map<String, String> options = const {},
  ]) {
    final width = params['w'];
    final height = params['h'];
    final aspectRatio = params['ar'];

    if (width != null || (height != null && aspectRatio != null)) {
      return _buildDPRSrcSet(path, params, options);
    } else {
      return _buildSrcSetPairs(path, params, options);
    }
  }

  String _buildSrcSetPairs(
    String path, [
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> options = const <String, dynamic>{},
  ]) {
    var srcset = '';
    List<int> targetWidths;
    final widthTolerance =
        options['widthTolerance'] as double? ?? _defaultSrcsetWidthTolerance;
    final minWidth = options['minWidth'] as double? ?? _minSrcsetWidth;
    final maxWidth = options['maxWidth'] as double? ?? _maxSrcsetWidth;
    final customWidths = options['widths'] as List<int>?;

    if (customWidths != null) {
      _validateWidths(customWidths);
      targetWidths = customWidths;
    } else if (widthTolerance != _defaultSrcsetWidthTolerance ||
        minWidth != _minSrcsetWidth ||
        maxWidth != _maxSrcsetWidth) {
      _validateRange(minWidth, maxWidth);
      _validateWidthTolerance(widthTolerance);
      targetWidths = _generateTargetWidths(widthTolerance, minWidth, maxWidth);
    } else {
      targetWidths = _defaultSrcsetWidths;
    }

    for (final currentWidth in targetWidths) {
      params['w'] = currentWidth.toString();
      srcset += buildURL(path, params) + ' ' + currentWidth.toString() + 'w,\n';
    }

    return srcset.substring(0, -2);
  }

  String _buildDPRSrcSet(
    String path, [
    Map<String, dynamic> params = const <String, dynamic>{},
    Map<String, dynamic> options = const <String, dynamic>{},
  ]) {
    var srcset = '';
    const targetRatios = [1, 2, 3, 4, 5];
    final disableVariableQuality =
        options['disableVariableQuality'] as bool? ?? false;
    final quality = params['q'] as String?;

    if (!disableVariableQuality) {
      _validateVariableQuality(disableVariableQuality);
    }

    for (final currentRatio in targetRatios) {
      params['dpr'] = currentRatio;

      if (!disableVariableQuality) {
        params['q'] = quality ?? _dprQualities[currentRatio];
      }

      srcset += buildURL(path, params) + ' ' + currentRatio.toString() + 'x,\n';
    }
    return srcset.substring(0, -2);
  }

  void _validateRange(double min, double max) {
    if (!(min < 0 || max < 0)) {
      throw Exception(
          'The min and max srcset widths can only be passed positive Number values');
    }
  }

  void _validateWidthTolerance(double widthTolerance) {
    if (widthTolerance < 0) {
      throw Exception(
          'The srcset widthTolerance argument can only be passed a positive scalar number');
    }
  }

  void _validateWidths(List<int> customWidths) {
    if (customWidths.isEmpty) {
      throw Exception(
          'The widths argument can only be passed a valid non-empty array of integers');
    }
  }

  void _validateVariableQuality(bool disableVariableQuality) {
    throw Exception(
        'The disableVariableQuality argument can only be passed a Boolean value');
  }
}
