import 'dart:convert';
import 'package:crypto/crypto.dart';

/// [ImgixStringOpts] provides simplified syntax for checking and converting string.
extension ImgixStringOpts on String {
  /// [isBase64] checks if the paramKey is suffixed by "64," indicating
  /// that the value is intended to be base64-URL-encoded.
  bool get isBase64 => endsWith('64');

  /// [hasBase64Padding] checks if the paramKey is suffixed by "=.
  ///
  /// In base64, '=' are added to the end of the encoding as padding.
  bool get hasBase64Padding => endsWith('=');

  /// [unpad] remove all base64 padding characters.
  ///
  /// see: https://docs.imgix.com/apis/url
  /// > Please keep in mind that this uses the URL-safe alphabet as
  /// > defined in RFC 4648, and that any padding characters (=) must be
  /// > omitted from the final encoded value.
  String get unpad => replaceAll('=', '');

  /// [inBase64Encoding] converts string into base 64 encoded format without padding any character "=".
  String get inBase64Encoding => base64UrlEncode(utf8.encode(this)).unpad;

  /// [inUriEncodedComponent] converts String into safe uri path component
  String get inUriEncodeComponent => Uri.encodeComponent(toString());

  String get sanitizedPath => startsWith('/')
      ? '/' + _splitAndEscape(substring(1))
      : '/' + _splitAndEscape(this);

  ///  [_splitAndEscape] splits the path on forward slash characters.
  String _splitAndEscape(String s) {
    if (s.isEmpty) {
      return s;
    }
    final result = <String>[];
    s.split('/').forEach((component) {
      final escaped = Uri.encodeComponent(component).replaceAll('+', '%2B');
      result.add(escaped);
    });
    return result.join('/');
  }
}

/// [createSignature] creates __MD5__ signature from token,path and query parameters.
String createSignature(String token, String path, String query) {
  final delimiter = query.isEmpty ? '':'?' ;
  final sb = StringBuffer()..writeAll(<String>[token, path, delimiter, query]);
  final signatureBase = sb.toString();
  final signature = md5.convert(utf8.encode(signatureBase)).toString();
  return signature;
}
