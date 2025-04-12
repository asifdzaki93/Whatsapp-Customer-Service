class Whatsapp {
  final int? id;
  final String name;
  final String? status;
  final String? qrcode;

  Whatsapp({this.id, required this.name, this.status, this.qrcode});

  factory Whatsapp.fromJson(Map<String, dynamic> json) {
    return Whatsapp(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      qrcode: json['qrcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'status': status, 'qrcode': qrcode};
  }
}
