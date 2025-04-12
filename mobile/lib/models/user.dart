import 'company.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? profile;
  final int companyId;
  final bool online;
  final Company? company;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
    required this.companyId,
    this.online = false,
    this.company,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profile: json['profile'],
      companyId: json['companyId'] ?? 0,
      online: json['online'] ?? false,
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile': profile,
      'companyId': companyId,
      'online': online,
      'company': company?.toJson(),
    };
  }
}
