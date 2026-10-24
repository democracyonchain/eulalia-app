import 'package:flutter_test/flutter_test.dart';
import 'package:eulalia_app/features/auth/data/models/registro_estado_model.dart';

void main() {
  test('parses registration readiness and prerequisite flags', () {
    final status = RegistroEstadoDto.fromJson({
      'cedula': '123',
      'base_ok': true,
      'ssi_ok': true,
      'bio_ok': false,
      'ready_for_affiliation': false,
      'ssi_status': 'CredentialIssued',
      'bio_status': 'not_started',
    });

    expect(status.baseOk, isTrue);
    expect(status.ssiOk, isTrue);
    expect(status.bioOk, isFalse);
    expect(status.readyForAffiliation, isFalse);
  });
}
