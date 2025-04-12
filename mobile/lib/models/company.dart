class Company {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final bool status;
  final DateTime dueDate;
  final String recurrence;
  final List<dynamic> schedules;
  final int planId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CompanySetting> settings;

  Company({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.status,
    required this.dueDate,
    required this.recurrence,
    required this.schedules,
    required this.planId,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      status: json['status'],
      dueDate: DateTime.parse(json['dueDate']),
      recurrence: json['recurrence'],
      schedules: json['schedules'],
      planId: json['planId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      settings:
          (json['settings'] as List)
              .map((setting) => CompanySetting.fromJson(setting))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'recurrence': recurrence,
      'schedules': schedules,
      'planId': planId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'settings': settings.map((setting) => setting.toJson()).toList(),
    };
  }
}

class CompanySetting {
  final int id;
  final String key;
  final String value;
  final int companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanySetting({
    required this.id,
    required this.key,
    required this.value,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanySetting.fromJson(Map<String, dynamic> json) {
    return CompanySetting(
      id: json['id'],
      key: json['key'],
      value: json['value'],
      companyId: json['companyId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'companyId': companyId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
