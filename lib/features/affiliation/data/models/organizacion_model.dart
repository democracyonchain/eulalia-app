class OrganizacionDto {
  final int organizacionId;
  final String nombre;
  final String tipo;
  final String estado;

  OrganizacionDto({
    required this.organizacionId,
    required this.nombre,
    required this.tipo,
    required this.estado,
  });

  factory OrganizacionDto.fromJson(Map<String, dynamic> json) {
    return OrganizacionDto(
      organizacionId: json['organizacionId'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? 'Organización sin nombre',
      tipo: json['tipo'] as String? ?? 'No definido',
      estado: json['estado'] as String? ?? 'pendiente',
    );
  }
}
