import 'package:flutter_test/flutter_test.dart';
import 'package:launchdesk/core/models/enums.dart';

void main() {
  test('default particle configuration is valid', () {
    const config = ParticleConfig();
    expect(config.count, greaterThan(0));
    expect(config.size, greaterThan(0));
  });
}
