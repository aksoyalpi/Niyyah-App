import 'package:flutter_test/flutter_test.dart';
import 'package:niyyah_app/features/blocklist/data/ios_bridge.dart';

void main() {
  test('authorization status maps Family Controls codes', () {
    expect(
      IosAuthorizationStatus.fromCode(0),
      IosAuthorizationStatus.notDetermined,
    );
    expect(IosAuthorizationStatus.fromCode(1), IosAuthorizationStatus.denied);
    expect(IosAuthorizationStatus.fromCode(2), IosAuthorizationStatus.approved);
  });

  test('unknown authorization codes fall back to notDetermined', () {
    expect(
      IosAuthorizationStatus.fromCode(-1),
      IosAuthorizationStatus.notDetermined,
    );
    expect(
      IosAuthorizationStatus.fromCode(9),
      IosAuthorizationStatus.notDetermined,
    );
  });
}
