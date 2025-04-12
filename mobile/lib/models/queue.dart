class Queue {
  final int id;
  final String name;
  final String color;
  final String? description;
  final bool isActive;
  final String? greetingMessage;
  final String? orderQueue;

  Queue({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.isActive,
    this.greetingMessage,
    this.orderQueue,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    print('Parsing queue JSON: $json');
    return Queue(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      color: json['color'] ?? '#000000',
      description: json['description'],
      isActive: json['isActive'] ?? true,
      greetingMessage: json['greetingMessage'],
      orderQueue: json['orderQueue']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'description': description,
      'isActive': isActive,
      'greetingMessage': greetingMessage,
      'orderQueue': orderQueue,
    };
  }
}
