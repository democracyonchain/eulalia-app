class SSIDto {
  final int? ssiId;
  final String cedula;
  final String? did;
  final String? schemaId;
  final String? credentialId;
  final DateTime fechaEmision;
  final String estado;

  SSIDto({
    this.ssiId,
    required this.cedula,
    this.did,
    this.schemaId,
    this.credentialId,
    required this.fechaEmision,
    required this.estado,
  });

  factory SSIDto.fromJson(Map<String, dynamic> json) {
    return SSIDto(
      ssiId: json['ssi_Id'] as int?,
      cedula: json['cedula'] as String,
      did: json['did'] as String?,
      schemaId: json['schemaId'] as String?,
      credentialId: json['credentialId'] as String?,
      fechaEmision: DateTime.parse(json['fecha_Emision'] as String),
      estado: json['estado'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ssiId != null) 'ssi_Id': ssiId,
      'cedula': cedula,
      'did': did,
      'schemaId': schemaId,
      'credentialId': credentialId,
      'fecha_Emision': fechaEmision.toIso8601String(),
      'estado': estado,
    };
  }
}
