class File {
  final int id;
  final int companyId;
  final String name;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<FileOption> options;

  File({
    required this.id,
    required this.companyId,
    required this.name,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory File.fromJson(Map<String, dynamic> json) {
    return File(
      id: json['id'],
      companyId: json['companyId'],
      name: json['name'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      options:
          (json['options'] as List)
              .map((option) => FileOption.fromJson(option))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'name': name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}

class FileOption {
  final int id;
  final int fileId;
  final String name;
  final String path;
  final String mediaType;
  final DateTime createdAt;
  final DateTime updatedAt;

  FileOption({
    required this.id,
    required this.fileId,
    required this.name,
    required this.path,
    required this.mediaType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FileOption.fromJson(Map<String, dynamic> json) {
    return FileOption(
      id: json['id'],
      fileId: json['fileId'],
      name: json['name'],
      path: json['path'],
      mediaType: json['mediaType'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileId': fileId,
      'name': name,
      'path': path,
      'mediaType': mediaType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
