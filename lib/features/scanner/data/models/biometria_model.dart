class BiometriaDto {
  final String cedula;
  final String estado; // 'pendiente' | 'verificado'
  final DateTime? fechaRegistro;

  BiometriaDto({
    required this.cedula,
    required this.estado,
    this.fechaRegistro,
  });

  factory BiometriaDto.fromJson(Map<String, dynamic> json) {
    return BiometriaDto(
      cedula: json['cedula'] as String,
      estado: json['estado'] as String,
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'estado': estado,
      'fechaRegistro': fechaRegistro?.toIso8601String(),
    };
  }
}
