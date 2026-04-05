class SSIInvitationDto {
  final String invitationId;
  final String invitationUrl;
  final String status;
  final DateTime? expiresAt;

  SSIInvitationDto({
    required this.invitationId,
    required this.invitationUrl,
    required this.status,
    this.expiresAt,
  });

  factory SSIInvitationDto.fromJson(Map<String, dynamic> json) {
    return SSIInvitationDto(
      invitationId: json['invitationId'] as String? ?? '',
      invitationUrl: json['invitationUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'Unknown',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }
}

class SSIStatusDto {
  final String status;
  final DateTime? lastUpdated;
  final String? details;
  final String? error;

  SSIStatusDto({
    required this.status,
    this.lastUpdated,
    this.details,
    this.error,
  });

  factory SSIStatusDto.fromJson(Map<String, dynamic> json) {
    return SSIStatusDto(
      status: json['status'] as String? ?? 'Unknown',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
      details: json['details'] as String?,
      error: json['error'] as String?,
    );
  }
}
