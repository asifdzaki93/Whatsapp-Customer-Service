class Ticket {
  final int id;
  final String status;
  final String subject;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? closedAt;
  final String? lastMessage;
  final int? userId;
  final int? contactId;
  final int? queueId;
  final int? whatsappId;
  final int? unreadMessages;
  final Contact? contact;
  final User? user;
  final Queue? queue;
  final Whatsapp? whatsapp;
  final bool isGroup;
  final bool chatbot;
  final int? queueOptionId;
  final int companyId;
  final String uuid;
  final bool useIntegration;
  final int? integrationId;
  final String? typebotSessionId;
  final bool typebotStatus;
  final String? promptId;
  final bool fromMe;
  final int amountUsedBotQueues;
  final List<String> tags;

  Ticket({
    required this.id,
    required this.status,
    this.subject = '',
    this.content = '',
    required this.createdAt,
    this.updatedAt,
    this.closedAt,
    this.lastMessage,
    this.userId,
    this.contactId,
    this.queueId,
    this.whatsappId,
    this.unreadMessages,
    this.contact,
    this.user,
    this.queue,
    this.whatsapp,
    required this.isGroup,
    required this.chatbot,
    this.queueOptionId,
    required this.companyId,
    required this.uuid,
    required this.useIntegration,
    this.integrationId,
    this.typebotSessionId,
    required this.typebotStatus,
    this.promptId,
    required this.fromMe,
    required this.amountUsedBotQueues,
    required this.tags,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      status: json['status'],
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      closedAt:
          json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
      lastMessage: json['lastMessage']?.toString(),
      userId: json['userId'],
      contactId: json['contactId'],
      queueId: json['queueId'],
      whatsappId: json['whatsappId'],
      unreadMessages: json['unreadMessages'] ?? 0,
      contact:
          json['contact'] != null ? Contact.fromJson(json['contact']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      queue: json['queue'] != null ? Queue.fromJson(json['queue']) : null,
      whatsapp:
          json['whatsapp'] != null ? Whatsapp.fromJson(json['whatsapp']) : null,
      isGroup: json['isGroup'] ?? false,
      chatbot: json['chatbot'] ?? false,
      queueOptionId: json['queueOptionId'],
      companyId: json['companyId'],
      uuid: json['uuid'],
      useIntegration: json['useIntegration'] ?? false,
      integrationId: json['integrationId'],
      typebotSessionId: json['typebotSessionId'],
      typebotStatus: json['typebotStatus'] ?? false,
      promptId: json['promptId'],
      fromMe: json['fromMe'] ?? false,
      amountUsedBotQueues: json['amountUsedBotQueues'] ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'subject': subject,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'lastMessage': lastMessage,
      'userId': userId,
      'contactId': contactId,
      'queueId': queueId,
      'whatsappId': whatsappId,
      'unreadMessages': unreadMessages,
      'contact': contact?.toJson(),
      'user': user?.toJson(),
      'queue': queue?.toJson(),
      'whatsapp': whatsapp?.toJson(),
      'isGroup': isGroup,
      'chatbot': chatbot,
      'queueOptionId': queueOptionId,
      'companyId': companyId,
      'uuid': uuid,
      'useIntegration': useIntegration,
      'integrationId': integrationId,
      'typebotSessionId': typebotSessionId,
      'typebotStatus': typebotStatus,
      'promptId': promptId,
      'fromMe': fromMe,
      'amountUsedBotQueues': amountUsedBotQueues,
      'tags': tags,
    };
  }
}

class Contact {
  final int id;
  final String name;
  final String? email;
  final String? number;
  final String? profilePicUrl;
  final bool? ignoreMessages;

  Contact({
    required this.id,
    required this.name,
    this.email,
    this.number,
    this.profilePicUrl,
    this.ignoreMessages,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      number: json['number'],
      profilePicUrl: json['profilePicUrl'],
      ignoreMessages: json['ignoreMessages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'number': number,
      'profilePicUrl': profilePicUrl,
      'ignoreMessages': ignoreMessages,
    };
  }
}

class Queue {
  final int id;
  final String name;
  final String? color;
  final String? greetingMessage;

  Queue({
    required this.id,
    required this.name,
    this.color,
    this.greetingMessage,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      greetingMessage: json['greetingMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'greetingMessage': greetingMessage,
    };
  }
}

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

class User {
  final int id;
  final String name;
  final String? email;
  final String? profile;
  final int? companyId;
  final bool online;

  User({
    required this.id,
    required this.name,
    this.email,
    this.profile,
    this.companyId,
    required this.online,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profile: json['profile'],
      companyId: json['companyId'],
      online: json['online'] ?? false,
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
    };
  }
}
