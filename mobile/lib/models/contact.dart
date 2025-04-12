class Contact {
  final int id;
  final String name;
  final String number;
  final String? email;
  final bool ignoreMessages;
  final String? profilePicUrl;
  final int companyId;
  final Map<String, dynamic>? extraInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profilePic;

  Contact({
    required this.id,
    required this.name,
    required this.number,
    this.email,
    required this.ignoreMessages,
    this.profilePicUrl,
    required this.companyId,
    this.extraInfo,
    required this.createdAt,
    required this.updatedAt,
    this.profilePic,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      number: json['number'],
      email: json['email'],
      ignoreMessages: json['ignoreMessages'] ?? false,
      profilePicUrl: json['profilePicUrl'],
      companyId: json['companyId'],
      extraInfo: json['extraInfo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'number': number,
      'email': email,
      'ignoreMessages': ignoreMessages,
      'profilePicUrl': profilePicUrl,
      'companyId': companyId,
      'extraInfo': extraInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profilePic': profilePic,
    };
  }
}
