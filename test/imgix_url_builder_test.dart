import 'package:imgix_core_dart/constants.dart' as constants;
import 'package:imgix_core_dart/model/srcset_option.dart';
import 'package:imgix_core_dart/url_builder.dart';
import 'package:test/test.dart';

void main() {
  group('ImgixURLBuilder', () {
    group('constructor', () {
      test('does not accept invalid domain', () {
        const hostWithLeadingSlash = '/my-host.imgix.net';
        const hostWithTrailingSlash = 'my-host.imgix.net/';
        const hostWithScheme = 'https://my-host.imgix.net';
        expect(() => URLBuilder(domain: hostWithLeadingSlash),
            throwsFormatException,
            reason: 'domain must not contains any leading slash');
        expect(() => URLBuilder(domain: hostWithTrailingSlash),
            throwsFormatException,
            reason: 'domain must not contains any trailing slash');
        expect(() => URLBuilder(domain: hostWithScheme), throwsFormatException,
            reason: 'domain must not contains any scheme');
      });
    });
    group('by default', () {
      test('generates https url', () {
        const host = 'my-host.imgix.net';
        final b = URLBuilder(domain: host);
        expect(b.createURLString('/path').startsWith('https://'), true);
      });
      test('generated urls do not have any query parameters', () {
        const host = 'my-host.imgix.net';
        final b = URLBuilder(domain: host);
        expect(b.createURLString('/path').endsWith('/path'), true);
      });
    });
    group('if specified', () {
      test('generates a http url', () {
        const host = 'my-host.imgix.net';
        final b = URLBuilder(domain: host, shouldUseHttpsByDefault: false);
        expect(b.createURLString('/path').startsWith('http://'), true);
      });
      test('generates an url with lib param', () {
        const host = 'my-host.imgix.net';
        final b = URLBuilder(domain: host, includeLibParam: true);
        expect(
            b
                .createURLString('/path')
                .contains('ixlib=dart-${constants.IMGIX_LIB_VERSION}'),
            true);
      });
      test('generates a signed url', () {
        const host = 'my-host.imgix.net';
        const sign = 'token';
        final b = URLBuilder(domain: host, defaultSignKey: sign);
        const path = '/path/to/image.jpg';
        expect(b.createURLString(path),
            'https://my-host.imgix.net/path/to/image.jpg?s=f1569e4cf5a82e101be6401d4d9d5397');
      });
    });
    group('createUrl', () {
      test('returns a correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const sign = 'token';
        final b = URLBuilder(domain: host, defaultSignKey: sign);
        const path = '/path/to/image.jpg';
        const expectedSignature = 'f1569e4cf5a82e101be6401d4d9d5397';
        final uri = b.createURL(path);
        expect(uri.queryParameters['s'], expectedSignature);
        expect(uri.host, host);
        expect(uri.path, path);
      });
      test(
          'returns a correct imgix URL even if path contains special characters',
          () {
        const host = 'my-host.imgix.net';
        const sign = 'token';
        final b = URLBuilder(domain: host, defaultSignKey: sign);
        const path = '/path/to/ <>[]{}|\\^%.jpg';
        const expectedPath = '/path/to/%20%3C%3E%5B%5D%7B%7D%7C%5C%5E%25.jpg';
        const expectedSignature = '6f6df3b7bca4968850009def43c1a4e7';
        final uri = b.createURL(path);
        final string = b.createURLString(path);
        expect(uri.queryParameters['s'], expectedSignature);
        expect(uri.host, host);
        expect(uri.path, expectedPath);
        expect(
            'https://' +
                uri.host +
                uri.path +
                '?s=' +
                uri.queryParameters['s']!,
            string);
      });
    });
    group('.createUrlString(<valid path)', () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = 'foo/bar/buzz';
        const pathWithSlash = '/' + path;
        final builder = URLBuilder(domain: host);
        expect(builder.createPlainURLString(path), 'https://$host/$path');
        expect(builder.createPlainURLString(path),
            builder.createPlainURLString(pathWithSlash));
      });
    });
    group('.createUrlString(<path starts with /)', () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = URLBuilder(domain: host);
        expect(builder.createPlainURLString(path), 'https://$host$path');
      });
    });
    group(
        '.createUrlString(<path with non empty string containing special characters)',
        () {
      test('returns correct imgix URL', () {
        const host = 'my-host.imgix.net';
        const path = '#foo/:bar/?buzz/';
        final builder = URLBuilder(domain: host);
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
        final builder = URLBuilder(domain: host);
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
        final builder = URLBuilder(domain: host, includeLibParam: true);
        expect(builder.createPlainURLString(path),
            'https://$host$path?ixlib=dart-${constants.IMGIX_LIB_VERSION}');
      });
    });
    group('.createUrlString(<valid path) with plain params', () {
      test('returns an Uri instance', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = URLBuilder(domain: host);
        expect(
            builder.createURLString(path, params: {'h': '300', 'w\$': '\$400'}),
            'https://$host$path?h=300&w%24=%24400');
      });
    });
    group('.createUrlString(<valid path) with base64 params', () {
      test('returns an Uri instance', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = URLBuilder(domain: host);
        expect(builder.createURLString(path, params: {'txt64': 'lorem ipsum'}),
            'https://$host$path?txt64=bG9yZW0gaXBzdW0');
      });
    });
    group('.createUrlString(<valid path) with signKey', () {
      test('returns an Uri instance', () {
        const host = 'my-social-network.imgix.net';
        const path = '/users/1.png';
        final builder = URLBuilder(domain: host, defaultSignKey: 'FOO123bar');
        expect(builder.createPlainURLString(path),
            'https://my-social-network.imgix.net/users/1.png?s=6797c24146142d5b40bde3141fd3600c');
      });
    });
    group('.createUrl(<valid path)', () {
      test('returns an Uri instance', () {
        const host = 'my-host.imgix.net';
        const path = '/foo/bar/buzz';
        final builder = URLBuilder(domain: host);
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
        final builder = URLBuilder(domain: host, includeLibParam: true);
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
        final builder = URLBuilder(domain: host);
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
        final builder = URLBuilder(domain: host);
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
        final builder = URLBuilder(domain: host);
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
        final builder = URLBuilder(domain: host);
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
