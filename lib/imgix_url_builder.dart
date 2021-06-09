library imgix_core_dart;

import 'dart:core';
import 'package:imgix_core_dart/encoding.dart';
import 'package:imgix_core_dart/constants.dart' as constants;
import 'package:imgix_core_dart/model/srcset_option.dart';
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
    if (!isValidDomain) {
      throw const FormatException(
          'Domain must not be empty and must be passed in as fully-qualified domain name '
          'and should not include a protocol or any path element, i.e. "example.imgix.net".');
    }
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
    _useHttpsByDefault = useHttps;
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

  // todo: check that a signature will not change after being parsed.
  Uri createURL(String path) {
    return Uri.parse(createPlainURLString(path));
  }

  /// [createPlainURLString] generates imgix url with default options.
  ///
  /// i.e. `createPlainURLString(/foo/bar/buzz)` returns 'https://example.com/foo/bar/buzz'
  ///
  /// Generated url may contain `ixlib`(library version) and `s`(signature) parameters.
  String createPlainURLString(String path) {
    return createURLString(path);
  }

  List<String> createURLStrings(Iterable<String> paths,
      {Map<String, String>? sharedParams,
      bool? useHttps,
      bool? includeLibraryParams}) {
    return [];
  }

  /// [createURLString] generates imgix url with optional query parameters
  /// - If [useHttps] is given, default setting([shouldUseHttpsByDefault]) is overridden.
  /// - If [includeLibraryParams] is given, default setting([_shouldIncludeLibParamByDefault]) is overridden.
  String createURLString(String path,
      {Map<String, String> params = const <String, String>{},
      bool? useHttps,
      bool? includeLibraryParams}) {
    path = path.sanitizedPath;
    params = _joinWithMetaParams(params, includeLibParam: includeLibraryParams);
    var queryParams = buildParams(params);
    if (_signKey?.isNotEmpty ?? false) {
      queryParams = withSignature(path, queryParams, _signKey!);
    }
    final delimiter = queryParams.isEmpty ? '' : '?';
    if (useHttps == null) {
      return _urlPrefix() + _domain + path + delimiter + queryParams;
    } else {
      final urlPrefix = useHttps ? 'https://' : 'http://';
      return urlPrefix + _domain + path + delimiter + queryParams;
    }
  }

  String buildSrcset(String path,
      {Map<String, String> params = const <String, String>{},
      SrcsetOption options = const SrcsetOption.base()}) {
    if (_shouldBuildDPRBasedSrcset(params)) {
      return _buildSrcsetList(buildDPRBasedSrcsetEntries(path, params: params),
          suffixBuilder: (e) => '${e.key}x').join(',\n');
    }
    final targets = options.generateTargetWidths();
    return _buildSrcsetList(
            buildSrcsetEntries(path, params: params, targets: targets))
        .join(',\n');
  }

  String createSrcsetFromWidths(String path,
      {Map<String, String> params = const <String, String>{},
      required List<int> widths}) {
    if (!validators.isValidWidths(widths)) {
      throw const InvalidWidthsException(
          message: 'Widths must not be empty and all width must be positive.');
    }
    final entries = buildSrcsetEntries(path, params: params, targets: widths);
    return _buildSrcsetList(entries, suffixBuilder: (e) => '${e.key}w')
        .join(',\n');
  }

  Map<String, String> buildDPRBasedSrcsetEntries(String path,
      {Map<String, String> params = const <String, String>{}}) {
    return constants.DPR_QUALITIES.map<String, String>((key, value) {
      final _params = _withDPRParams(params, key);
      return MapEntry(key.toString(), createURLString(path, params: _params));
    });
  }

  /// [buildSrcsetEntries] returns srcset urls paired with width as Map<int,String>. Key is width and value is path.
  Map<int, String> buildSrcsetEntries(String path,
      {Map<String, String> params = const <String, String>{},
      required Iterable<int> targets}) {
    return targets.fold<Map<int, String>>(<int, String>{}, (acc, element) {
      acc[element] =
          createURLString(path, params: {...params, 'w': element.toString()});
      return acc;
    });
  }

  /// [_buildSrcsetList] converts srcset entries into list. Each urls are joined with space and suffix.
  List<String> _buildSrcsetList<T>(Map<T, String> srcsetEntries,
      {String Function(MapEntry<T, String>)? suffixBuilder}) {
    return srcsetEntries.entries.fold<List<String>>(<String>[], (acc, e) {
      suffixBuilder ??= (e) => '${e.key}w';
      acc.add(_createImageCandidateString(e.value, suffixBuilder!(e)));
      return acc;
    });
  }

  /// [_createImageCandidateString] joins a URL with a space and a suffix in order
  /// to create an image candidate string. For more information see:
  /// https://html.spec.whatwg.org/multipage/images.html#srcset-attributes
  String _createImageCandidateString(String path, String suffix) {
    return path + ' ' + suffix;
  }

  @visibleForTesting

  /// [buildParams] uri-encodes query parameter keys and values, and then concatenates them into String with delimiter '&'.
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
      if (includeLibParam ?? _shouldIncludeLibParamByDefault)
        ...constants.metaParams
    };
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

  /// [_shouldBuildDPRBasedSrcset] determines if we can infer from params whether we need
  /// to create a dpr-based srcset attribute. If a width ("w") is present
  /// or if both the height ("h") and the aspect ratio ("ar") are present,
  /// then we can infer the desired srcset is dpr-based.
  bool _shouldBuildDPRBasedSrcset(Map<String, String> params) {
    return (params['w']?.isNotEmpty ?? false) ||
        ((params['h']?.isNotEmpty ?? false) &
            (params['ar']?.isNotEmpty ?? false));
  }

  @visibleForTesting

  /// [withSignature] adds md5 signature to query parameter.
  String withSignature(String path, String queryParams, String signKey) {
    final signature = createSignature(signKey, path, queryParams);
    if (queryParams.isNotEmpty) {
      return queryParams = queryParams + '&s=' + signature;
    } else {
      return queryParams = 's=' + signature;
    }
  }

  /// [_withDPRParams] updates query parameters with dpr params.
  ///
  /// If the original params contain a valid dpr option, that value is used,
  /// otherwise, dpr quality parameter `q` is added according to [dprRatio] argument.
  Map<String, String> _withDPRParams(Map<String, String> params, int dprRatio) {
    return {
      ...params,
      'dpr': '$dprRatio',
      if (params['q'] == null) ...{
        'q': constants.DPR_QUALITIES[dprRatio].toString()
      }
    };
  }
}

class InvalidWidthsException implements Exception {
  const InvalidWidthsException({required this.message});

  final String message;
}
