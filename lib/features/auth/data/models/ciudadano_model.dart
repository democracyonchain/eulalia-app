class CiudadanoDto {
  final String cedula;
  final String nombres;
  final String apellidos;
  final String email;
  final String? telefono;
  final DateTime fechaNacimiento;

  CiudadanoDto({
    required this.cedula,
    required this.nombres,
    required this.apellidos,
    required this.email,
    this.telefono,
    required this.fechaNacimiento,
  });

  // From JSON (API response)
  factory CiudadanoDto.fromJson(Map<String, dynamic> json) {
    return CiudadanoDto(
      cedula: json['cedula'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      fechaNacimiento: DateTime.parse(json['fechaNacimiento'] as String),
    );
  }

  // To JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'nombres': nombres,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
    };
  }
}
