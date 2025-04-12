class Connection {
  final int id;
  final String name;
  final String? session;
  final String? qrCode;
  final String status;
  final DateTime? lastUpdate;
  final String provider;
  final bool isDefault;
  final int companyId;

  Connection({
    required this.id,
    required this.name,
    this.session,
    this.qrCode,
    required this.status,
    this.lastUpdate,
    required this.provider,
    required this.isDefault,
    required this.companyId,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      name: json['name'],
      session: json['session'],
      qrCode: json['qrcode'],
      status: json['status'],
      lastUpdate:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      provider: json['provider'],
      isDefault: json['isDefault'],
      companyId: json['companyId'],
    );
  }

  Connection copyWith({
    int? id,
    String? name,
    String? session,
    String? qrCode,
    String? status,
    DateTime? lastUpdate,
    String? provider,
    bool? isDefault,
    int? companyId,
  }) {
    return Connection(
      id: id ?? this.id,
      name: name ?? this.name,
      session: session ?? this.session,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      provider: provider ?? this.provider,
      isDefault: isDefault ?? this.isDefault,
      companyId: companyId ?? this.companyId,
    );
  }
}
