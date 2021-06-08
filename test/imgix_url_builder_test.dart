import 'package:imgix_core_dart/imgix_url_builder.dart';
import 'package:imgix_core_dart/model/srcset_option.dart';
import 'package:test/test.dart';
import 'package:imgix_core_dart/constants.dart' as constants;

void main() {
  group('ImgixURLBuilder', () {
    group('constructor', () {
      test('does not accept invalid domain', () {
        const hostWithLeadingSlash = '/my-host.imgix.net';
        const hostWithTrailingSlash = 'my-host.imgix.net/';
        expect(() => ImgixURLBuilder(domain: hostWithLeadingSlash),
            throwsFormatException,
            reason: 'domain must not contains any leading characters');
        expect(() => ImgixURLBuilder(domain: hostWithTrailingSlash),
            throwsFormatException,
            reason: 'domain must not contains any trailing characters');
      });
    });
    group('by default', () {
      test('generates https url', () {
        const host = 'my-host.imgix.net';
        final b = ImgixURLBuilder(domain: host);
        expect(b.createURLString('/path').startsWith('https'), true);
      });
      test('generated urls do not have any query parameters', () {
        const host = 'my-host.imgix.net';
        final b = ImgixURLBuilder(domain: host);
        expect(b.createURLString('/path').endsWith('/path'), true);
      });
    });
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
    group(
        '.createUrlString(<path with non empty string containing special characters)',
        () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = '#foo/:bar/?buzz/';
        final builder = ImgixURLBuilder(domain: host);
        final result = builder.createPlainURLString(path);
        expect(result.contains('#'), false);
        expect(result.contains('?'), false);
        expect(result, 'https://$host/%23foo/%3Abar/%3Fbuzz/');
      });
    });
    group('.createUrlString(<path with special characters)', () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = '#/:/?/';
        final builder = ImgixURLBuilder(domain: host);
        final result = builder.createPlainURLString(path);
        expect(result.contains('#'), false);
        expect(result.contains('?'), false);
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
    group('.createUrlString(<valid path) with signKey', () {
      test('returns an Uri instance', () {
        const host = 'my-social-network.imgix.net';
        const path = '/users/1.png';
        final builder =
            ImgixURLBuilder(domain: host, defaultSignKey: 'FOO123bar');
        expect(builder.createPlainURLString(path),
            'https://my-social-network.imgix.net/users/1.png?s=6797c24146142d5b40bde3141fd3600c');
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
    group('.createUrl(<valid path>) with lib param', () {
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
    group('.buildSrcsetFromWidths', () {
      test('returns a srcset', () {
        const host = 'my-host.imgix.net';
        const path = 'image.jpg';
        final builder = ImgixURLBuilder(domain: host);
        final srcset =
            builder.createSrcsetFromWidths(path, widths: [100, 200, 300, 400]);
        expect(
            srcset,
            'https://my-host.imgix.net/image.jpg?w=100 100w,\n'
            'https://my-host.imgix.net/image.jpg?w=200 200w,\n'
            'https://my-host.imgix.net/image.jpg?w=300 300w,\n'
            'https://my-host.imgix.net/image.jpg?w=400 400w');
      });
    });
    group('.buildSrcset from range', () {
      test('returns a srcset', () {
        const host = 'my-host.imgix.net';
        const path = 'image.jpg';
        final builder = ImgixURLBuilder(domain: host);
        final srcset = builder.buildSrcset(path,
            options:
                SrcsetOption(minWidth: 100, maxWidth: 380, tolerance: 0.08));
        expect(
            srcset,
            'https://my-host.imgix.net/image.jpg?w=100 100w,\n'
            'https://my-host.imgix.net/image.jpg?w=116 116w,\n'
            'https://my-host.imgix.net/image.jpg?w=134 134w,\n'
            'https://my-host.imgix.net/image.jpg?w=156 156w,\n'
            'https://my-host.imgix.net/image.jpg?w=182 182w,\n'
            'https://my-host.imgix.net/image.jpg?w=210 210w,\n'
            'https://my-host.imgix.net/image.jpg?w=244 244w,\n'
            'https://my-host.imgix.net/image.jpg?w=282 282w,\n'
            'https://my-host.imgix.net/image.jpg?w=328 328w,\n'
            'https://my-host.imgix.net/image.jpg?w=380 380w');
      });
    });
    group('.buildSrcset with fixed width', () {
      test('returns a srcset', () {
        const host = 'my-host.imgix.net';
        const path = 'image.jpg';
        final builder = ImgixURLBuilder(domain: host);
        final srcset = builder.buildSrcset(path, params: {'w': '320'});
        expect(
            srcset,
            'https://my-host.imgix.net/image.jpg?w=320&dpr=1&q=75 1x,\n'
            'https://my-host.imgix.net/image.jpg?w=320&dpr=2&q=50 2x,\n'
            'https://my-host.imgix.net/image.jpg?w=320&dpr=3&q=35 3x,\n'
            'https://my-host.imgix.net/image.jpg?w=320&dpr=4&q=23 4x,\n'
            'https://my-host.imgix.net/image.jpg?w=320&dpr=5&q=20 5x');
      });
    });
    group('.buildSrcset from height and aspect ratio', () {
      test('returns a srcset', () {
        const host = 'my-host.imgix.net';
        const path = 'image.jpg';
        final builder = ImgixURLBuilder(domain: host);
        final srcset =
            builder.buildSrcset(path, params: {'h': '320', 'ar': '4:3'});
        expect(
            srcset,
            'https://my-host.imgix.net/image.jpg?h=320&ar=4%3A3&dpr=1&q=75 1x,\n'
            'https://my-host.imgix.net/image.jpg?h=320&ar=4%3A3&dpr=2&q=50 2x,\n'
            'https://my-host.imgix.net/image.jpg?h=320&ar=4%3A3&dpr=3&q=35 3x,\n'
            'https://my-host.imgix.net/image.jpg?h=320&ar=4%3A3&dpr=4&q=23 4x,\n'
            'https://my-host.imgix.net/image.jpg?h=320&ar=4%3A3&dpr=5&q=20 5x');
      });
    });
  });
}
