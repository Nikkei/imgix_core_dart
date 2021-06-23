import 'package:imgix_core_dart/constants.dart' as constants;
import 'package:imgix_core_dart/model/srcset_option.dart';
import 'package:test/test.dart';

void main() {
  group('SrcsetOption', () {
    group('constructor', () {
      group('const constructor: SrcsetOption.base', () {
        test('returns default SrcsetOption', () {
          const so = SrcsetOption.base();
          expect(so.maxWidth, constants.DEFAULT_MAX_WIDTH);
          expect(so.minWidth, constants.DEFAULT_MIN_WIDTH);
          expect(so.tolerance, constants.SRCSET_DEFAULT_TOLERANCE);
        });
      });
      group('SrcsetOption', () {
        test('does not accept invalid parameters', () {
          expect(() => SrcsetOption(minWidth: 100, maxWidth: 80),
              throwsFormatException);
          expect(() => SrcsetOption(tolerance: -1), throwsFormatException);
        });
      });
    });
    group('generateTargetWidths', () {
      test('returns default widths by default', () {
        const so = SrcsetOption.base();
        expect(so.generateTargetWidths().length == 31, true);
      });
      test('returns numbers in ascending order within a valid range', () {
        const so = SrcsetOption.base();
        final w = so.generateTargetWidths();
        expect(w.first >= so.minWidth, true);
        expect(w.last <= so.maxWidth, true);
        for (var i = 0; i < w.length - 2; i++) {
          expect(w[i] <= w[i + 1], true);
        }
      });
      test('returns even numbers if custom parameters are provided', () {
        final so = SrcsetOption(minWidth: 120);
        expect(so.generateTargetWidths().any((element) => element % 2 == 1),
            false);
      });
      test('returns numbers in ascending order within a valid range', () {
        final so = SrcsetOption(minWidth: 120);
        final w = so.generateTargetWidths();
        expect(w.first >= so.minWidth, true);
        expect(w.last <= so.maxWidth, true);
        for (var i = 0; i < w.length - 2; i++) {
          expect(w[i] <= w[i + 1], true);
        }
      });
    });
  });
}
