import 'package:test/test.dart';

import 'package:imgix_core_dart/validators.dart' as validators;

void main(){
  group('validators',(){
    group('widths validator',(){
      test('returns true only if widths are not null and all widths are positive value',(){
        expect(validators.isValidWidths([]), false);
        expect(validators.isValidWidths([-100,10,-20,30]),false);
        expect(validators.isValidWidths([1,0,3]),true);
        expect(validators.isValidWidths([100,200,300]),true);
      });
    });
  });
}