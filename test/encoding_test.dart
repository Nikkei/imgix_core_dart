import 'dart:convert';

import 'package:test/test.dart';

import 'package:imgix_core_dart/encoding.dart';

void main(){
  group('encoding',(){

    group('String',(){
       test('isBase64',(){
         expect('64'.isBase64, true);
         expect('   64'.isBase64,true);
         expect('646464'.isBase64,true);
         expect('foo64'.isBase64,true);
       } );
       test('is not base 64',(){
         expect('6 4'.isBase64, false);
         expect('646464 '.isBase64, false);
         expect('\x40'.isBase64,false);
       });
    });
    group('inBase64encoding',(){
      test('is base 64',(){
        expect('Hello, 世界'.inBase64Encoding,'SGVsbG8sIOS4lueVjA');
        const original = 'Avenir Next Demi,Bold';
        final got = original.inBase64Encoding;
        expect(got, 'QXZlbmlyIE5leHQgRGVtaSxCb2xk');
        expect(utf8.decode(base64.decode(got)),original);
        expect('I cannøt belîév∑ it wors! 😱'.inBase64Encoding,'SSBjYW5uw7h0IGJlbMOuw6l24oiRIGl0IHdvcu-jv3MhIPCfmLE');
        expect('Hello,+World!'.inBase64Encoding,'SGVsbG8sK1dvcmxkIQ');
      });
    });
  });
}