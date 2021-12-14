import 'dart:convert';

import 'package:imgix_core_dart/encoding.dart';
import 'package:test/test.dart';

void main() {
  group('encoding', () {
    group('String', () {
      test('isBase64', () {
        expect('64'.isBase64, true);
        expect('   64'.isBase64, true);
        expect('646464'.isBase64, true);
        expect('foo64'.isBase64, true);
      });
      test('is not base 64', () {
        expect('6 4'.isBase64, false);
        expect('646464 '.isBase64, false);
        expect('\x40'.isBase64, false);
      });
    });
    group('inBase64encoding', () {
      test('is base 64', () {
        expect('Hello, 世界'.inBase64Encoding, 'SGVsbG8sIOS4lueVjA');
        const original = 'Avenir Next Demi,Bold';
        final got = original.inBase64Encoding;
        expect(got, 'QXZlbmlyIE5leHQgRGVtaSxCb2xk');
        expect(utf8.decode(base64.decode(got)), original);
        expect('I cannøt belîév∑ it wors! 😱'.inBase64Encoding,
            'SSBjYW5uw7h0IGJlbMOuw6l24oiRIGl0IHdvcu-jv3MhIPCfmLE');
        expect('Hello,+World!'.inBase64Encoding, 'SGVsbG8sK1dvcmxkIQ');
      });
    });
    group('encode', () {
      test('encodes reserved delimiters', () {
        const path1 = ' <>[]{}|\\^%.jpg';
        const expected1 = '/%20%3C%3E%5B%5D%7B%7D%7C%5C%5E%25.jpg';
        expect(path1.sanitizedPath, expected1);
        const path2 = 'ساندویچ.jpg';
        const expected2 = '/%D8%B3%D8%A7%D9%86%D8%AF%D9%88%DB%8C%DA%86.jpg';
        expect(path2.sanitizedPath, expected2);
      });
    });
    group('signature', () {
      // note: https://github.com/imgix/imgix-blueprint#simple-paths
      test('generates correct signature', () {
        final s = createSignature('FOO123bar', '/users/1.png', '');
        expect(s, '6797c24146142d5b40bde3141fd3600c');
      });
      test('generates correct signature', () {
        final s = createSignature('FOO123bar', '/users/1.png', 'w=400&h=300');
        expect(s, 'c7b86f666a832434dd38577e38cf86d1');
      });
    });
    group('proxy', () {
      test('returns encoded proxy', () {
        const raw = 'http://www.this.com/pic.jpg';
        const expected = '/http%3A%2F%2Fwww.this.com%2Fpic.jpg';
        expect(raw.sanitizedPath, expected);
        expect(expected.sanitizedPath, expected);
      });
    });
  });
}
