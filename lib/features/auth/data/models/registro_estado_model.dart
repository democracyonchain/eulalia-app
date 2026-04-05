class RegistroEstadoDto {
  final String cedula;
  final bool baseOk;
  final bool ssiOk;
  final bool bioOk;
  final bool readyForAffiliation;
  final String ssiStatus;
  final String bioStatus;

  RegistroEstadoDto({
    required this.cedula,
    required this.baseOk,
    required this.ssiOk,
    required this.bioOk,
    required this.readyForAffiliation,
    required this.ssiStatus,
    required this.bioStatus,
  });

  factory RegistroEstadoDto.fromJson(Map<String, dynamic> json) {
    return RegistroEstadoDto(
      cedula: json['cedula'] as String? ?? '',
      baseOk: json['base_ok'] as bool? ?? false,
      ssiOk: json['ssi_ok'] as bool? ?? false,
      bioOk: json['bio_ok'] as bool? ?? false,
      readyForAffiliation: json['ready_for_affiliation'] as bool? ?? false,
      ssiStatus: json['ssi_status'] as String? ?? 'NotStarted',
      bioStatus: json['bio_status'] as String? ?? 'not_started',
    );
  }
}
