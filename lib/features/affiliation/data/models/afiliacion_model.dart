class AfiliacionDto {
  final int afiliacionId;
  final String cedula;
  final int organizacionId;
  final DateTime fechaAfiliacion;
  final String estado;

  AfiliacionDto({
    required this.afiliacionId,
    required this.cedula,
    required this.organizacionId,
    required this.fechaAfiliacion,
    required this.estado,
  });

  // From JSON (API response)
  factory AfiliacionDto.fromJson(Map<String, dynamic> json) {
    return AfiliacionDto(
      afiliacionId: json['afiliacionId'] as int,
      cedula: json['cedula'] as String,
      organizacionId: json['organizacionId'] as int,
      fechaAfiliacion: DateTime.parse(json['fechaAfiliacion'] as String),
      estado: json['estado'] as String,
    );
  }

  // To JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'afiliacionId': afiliacionId,
      'cedula': cedula,
      'organizacionId': organizacionId,
      'fechaAfiliacion': fechaAfiliacion.toIso8601String(),
      'estado': estado,
    };
  }
}

// Create Afiliacion Request (without ID)
class CreateAfiliacionRequest {
  final String cedula;
  final int organizacionId;

  CreateAfiliacionRequest({
    required this.cedula,
    required this.organizacionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'organizacionId': organizacionId,
      'fechaAfiliacion': DateTime.now().toIso8601String(),
      'estado': 'activa',
    };
  }
}
