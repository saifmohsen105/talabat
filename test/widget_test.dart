import 'package:flutter_test/flutter_test.dart';
import 'package:talabat_clone/app/theme.dart';

void main() {
  test('app theme uses Material 3', () {
    expect(AppTheme.light.useMaterial3, isTrue);
  });
}
