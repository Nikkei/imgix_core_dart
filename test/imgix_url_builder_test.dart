
import 'package:imgix_core_dart/imgix_url_builder.dart';
import 'package:test/test.dart';
import 'package:imgix_core_dart/constants.dart' as constants;

void main() {
  group('ImgixURLBuilder', () {
    group('.createUrlString(<valid path)', () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = 'foo/bar/buzz';
        final builder = ImgixURLBuilder(domain: host);
        expect(builder.createPlainURLString(path), 'https://$host/$path');
      });
    });
    group('.createUrlString(<path starts with /)', () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = ImgixURLBuilder(domain: host);
        expect(builder.createPlainURLString(path), 'https://$host$path');
      });
    });
    group('.createUrlString(<path with non empty string containing special characters)', () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = '#foo/:bar/?buzz/';
        final builder = ImgixURLBuilder(domain: host);
        final result = builder.createPlainURLString(path);
        expect(result.contains('#'),false);
        expect(result.contains('?'),false);
        expect(result, 'https://$host/%23foo/%3Abar/%3Fbuzz/');
      });
    });
    group('.createUrlString(<path with special characters)', () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = '#/:/?/';
        final builder = ImgixURLBuilder(domain: host);
        final result = builder.createPlainURLString(path);
        expect(result.contains('#'),false);
        expect(result.contains('?'),false);
        expect(result, 'https://$host/%23/%3A/%3F/');
      });
    });
    group('.createUrlString(<valid path) with lib param', () {
      test('returns an Uri instance', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = ImgixURLBuilder(domain: host, includeLibParam: true);
        expect(builder.createPlainURLString(path),
            'https://$host$path?ixlib=dart-${constants.IMGIX_LIB_VERSION}');
      });
    });
    group('.createUrl(<valid path)', () {
      test('returns an Uri instance', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = ImgixURLBuilder(domain: host);
        final uri = builder.createURL(path);
        expect(uri.host, host);
        expect(uri.path, path);
        expect(uri.scheme, 'https');
        expect(uri.queryParameters, <String, String>{});
      });
    });
    group('.createUrl(<valid path) with lib param', () {
      test('returns an Uri instance', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = ImgixURLBuilder(domain: host, includeLibParam: true);
        final uri = builder.createURL(path);
        expect(uri.host, host);
        expect(uri.path, path);
        expect(uri.scheme, 'https');
        expect(uri.queryParameters,
            <String, String>{'ixlib': 'dart-${constants.IMGIX_LIB_VERSION}'});
      });
    });
  });
}
