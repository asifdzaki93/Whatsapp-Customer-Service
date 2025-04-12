class Attachment {
  final String name;
  final String path;
  final String type;
  final int size;
  final String? url;

  Attachment({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    this.url,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'path': path, 'type': type, 'size': size, 'url': url};
  }
}
