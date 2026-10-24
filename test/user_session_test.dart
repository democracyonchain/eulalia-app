import 'package:flutter_test/flutter_test.dart';
import 'package:eulalia_app/core/store/user_session.dart';

void main() {
  test('stores citizen identity without requiring a PIN', () {
    final session = UserSession();
    session.logout();

    session.setIdentity(
      UserIdentity(name: 'Citizen', dni: '123', did: 'did:eulalia:test'),
    );

    expect(session.currentIdentity?.dni, '123');
    expect(session.currentIdentity?.pin, isNull);

    session.logout();
    expect(session.hasIdentity, isFalse);
  });
}
