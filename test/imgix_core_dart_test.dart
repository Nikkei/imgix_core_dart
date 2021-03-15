import 'package:imgix_core_dart/imgix_core_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Imgix client:', () {
    group('The constructor', () {
      test('initialize with correct defaults', () {
        final client = ImgixClient(domain: 'my-host.imgix.net');
        expect(client.domain, 'my-host.imgix.net');
        expect(client.secureURLToken, null);
        expect(client.useHTTPS, true);
      });

      test('initialize with a token', () {
        final client = ImgixClient(
          domain: 'my-host.imgix.net',
          secureURLToken: 'MYT0KEN',
        );
        expect(client.domain, 'my-host.imgix.net');
        expect(client.secureURLToken, 'MYT0KEN');
        expect(client.useHTTPS, true);
      });

      test('initializes in insecure mode', () {
        final client = ImgixClient(
          domain: 'my-host.imgix.net',
          secureURLToken: 'MYT0KEN',
          useHTTPS: false,
        );
        expect(client.domain, 'my-host.imgix.net');
        expect(client.secureURLToken, 'MYT0KEN');
        expect(client.useHTTPS, false);
      });

      group('errors with invalid domain', () {
        test('appended slash', () {
          expect(
            () => ImgixClient(domain: 'my-host1.imgix.net/'),
            throwsException,
          );
        });

        test('prepended scheme', () {
          expect(
            () => ImgixClient(domain: 'https://my-host1.imgix.net'),
            throwsException,
          );
        });

        test('appended dash', () {
          expect(
            () => ImgixClient(domain: 'my-host1.imgix.net-'),
            throwsException,
          );
        });
      });

      test('accepts a single domain name', () {
        const expectedUrl = 'https://my-host.imgix.net/image.jpg?ixlib=dart-' +
            ImgixClient.VERSION;
        final client = ImgixClient(domain: 'my-host.imgix.net');
        expect(client.domain, 'my-host.imgix.net');
        expect(client.buildURL('image.jpg'), expectedUrl);
      });
    });

    group('Calling _sanitizePath()', () {
      late ImgixClient client;

      setUpAll(() {
        client = ImgixClient(domain: 'testing.imgix.net');
      });

      group('with a simple path', () {
        const path = 'images/1.png';

        test('prepends a leading slash', () {
          final result = client.sanitizePath(path);
          expect(result.substring(0, 1), '/');
        });

        test('otherwise returns the same exact path', () {
          final result = client.sanitizePath(path);
          expect(result.substring(1), path);
        });
      });

      group('with a path that contains a leading slash', () {
        const path = '/images/1.png';

        test('prepends the leading slash', () {
          final result = client.sanitizePath(path);
          expect(result.substring(0, 1), '/');
        });

        test(
            'otherwise returns the same path, except with the characters encoded properly',
            () {
          final result = client.sanitizePath(path);
          expect(result.substring(1), path.substring(1));
        });
      });

      group('with a path that contains unencoded characters', () {
        const path = 'images/"image 1".png';

        test('prepends a leading slash', () {
          final result = client.sanitizePath(path);
          expect(result.substring(0, 1), '/');
        });

        test(
            'otherwise returns the same path, except with the characters encoded properly',
            () {
          final result = client.sanitizePath(path);
          expect(result.substring(1), Uri.encodeFull(path));
        });
      });

      group('with a path that contains a hash character', () {
        const path = '#blessed.png';

        test('properly encodes the hash character', () {
          final expectation = path.replaceFirst(RegExp(r'^#'), '%23');
          final result = client.sanitizePath(path);
          expect(result.substring(1), expectation);
        });
      });

      group('with a path that contains a question mark', () {
        const path = '?what.png';

        test('properly encodes the question mark', () {
          final expectation = path.replaceFirst(RegExp(r'^\?'), '%3F');
          final result = client.sanitizePath(path);
          expect(result.substring(1), expectation);
        });
      });

      group('with a path that contains a colon', () {
        const path = ':emoji.png';

        test('properly encodes the colon', () {
          final expectation = path.replaceFirst(RegExp(r'^\:'), '%3A');
          final result = client.sanitizePath(path);
          expect(result.substring(1), expectation);
        });
      });

      group('with a full HTTP URL', () {
        const path = 'http://example.com/images/1.png';

        test('prepends a leading slash, unencoded', () {
          final result = client.sanitizePath(path);
          expect(result.substring(0, 1), '/');
        });

        test('otherwise returns a fully-encoded version of the given URL', () {
          final result = client.sanitizePath(path);
          expect(result.substring(1), Uri.encodeComponent(path));
        });
      });

      group('with a full HTTPS URL', () {
        const path = 'https://example.com/images/1.png';

        test('prepends a leading slash, unencoded', () {
          final result = client.sanitizePath(path);
          expect(result.substring(0, 1), '/');
        });

        test('otherwise returns a fully-encoded version of the given URL', () {
          final result = client.sanitizePath(path);
          expect(result.substring(1), Uri.encodeComponent(path));
        });
      });

      group('with a full HTTP URL that contains a leading slash', () {
        const path = '/http://example.com/images/1.png';

        test('retains the leading slash, unencoded', () {
          final result = client.sanitizePath(path);
          expect(result.substring(0, 1), '/');
        });

        test('otherwise returns a fully-encoded version of the given URL', () {
          final result = client.sanitizePath(path);
          expect(result.substring(1), Uri.encodeComponent(path.substring(1)));
        });
      });

      group('with a full HTTPS URL that contains encoded characters', () {
        const path = 'http://example.com/images/1.png?foo=%20';

        test('prepends a leading slash, unencoded', () {
          final result = client.sanitizePath(path);
          expect(result.substring(0, 1), '/');
        });

        test('otherwise returns a fully-encoded version of the given URL', () {
          final result = client.sanitizePath(path);
          expect(result.substring(1), Uri.encodeComponent(path));
        });

        test('double-encodes the original encoded characters', () {
          final result = client.sanitizePath(path);
          expect(result.indexOf('%20'), -1);
          expect(result.indexOf('%2520'), Uri.encodeComponent(path).length - 4);
        });
      });
    });

    group('Calling _buildParams()', () {
      late ImgixClient client;

      setUp(() {
        client = ImgixClient(
          domain: 'testing.imgix.net',
          includeLibraryParam: false,
        );
      });

      test('returns an empty string if no parameters are given', () {
        final result = client.buildParams(<String, dynamic>{});
        expect(result, '');
      });

      test(
          'returns a properly-formatted query string if a single parameter is given',
          () {
        final params = <String, dynamic>{
          'w': 400,
        };
        const expectation = '?w=400';
        final result = client.buildParams(params);
        expect(result, expectation);
      });

      test(
          'returns a properly-formatted query string if multiple parameters are given',
          () {
        final params = <String, dynamic>{
          'w': 400,
          'h': 300,
        };
        const expectation = '?w=400&h=300';
        final result = client.buildParams(params);
        expect(result, expectation);
      });

      test('includes an `ixlib` param if the `libraryParam` setting is truthy',
          () {
        final params = <String, dynamic>{
          'w': 400,
        };
        const expectation = '?w=400&ixlib=test';
        client.libraryParam = 'test';
        final result = client.buildParams(params);
        expect(result, expectation);
      });

      test('url-encodes parameter keys properly', () {
        final params = <String, dynamic>{'w\$': 400};
        const expectation = '?w%24=400';
        final result = client.buildParams(params);
        expect(result, expectation);
      });

      test('url-encodes parameter values properly', () {
        final params = <String, dynamic>{'w': '\$400'};
        const expectation = '?w=%24400';
        final result = client.buildParams(params);
        expect(result, expectation);
      });

      test('base64-encodes parameter values whose keys end in `64`', () {
        final params = <String, dynamic>{
          'txt64': 'lorem ipsum',
        };
        const expectation = '?txt64=bG9yZW0gaXBzdW0';
        final result = client.buildParams(params);
        expect(result, expectation);
      });
    });

    group('Calling signParams()', () {
      late ImgixClient client;
      const path = 'images/1.png';

      setUp(() {
        client = ImgixClient(
          domain: 'testing.imgix.net',
          secureURLToken: 'MYT0KEN',
          includeLibraryParam: false,
        );
      });

      test(
          'returns a query string containing only a proper signature parameter, if no other query parameters are provided',
          () {
        const expectation = '?s=6d82410f89cc6d80a6aa9888dcf85825';
        final result = client.signParams(path, '');
        expect(result, expectation);
      });

      test(
          'returns a query string with a proper signature parameter appended, if other query parameters are provided',
          () {
        const expectation = '?w=400&s=990916ef8cc640c58d909833e47f6c31';
        final result = client.signParams(path, '?w=400');
        expect(result, expectation);
      });
    });

    group('Calling buildSrcSet()', () {
      // TODO: write a test!!
    });
  });
}
