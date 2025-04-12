import 'dart:convert';

class LinkPreview {
  final String? title;
  final String? description;
  final String? image;
  final String? url;

  LinkPreview({this.title, this.description, this.image, this.url});

  factory LinkPreview.fromJson(Map<String, dynamic> json) {
    return LinkPreview(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'url': url,
    };
  }
}

class Reaction {
  final String userId;
  final String emoji;

  Reaction({required this.userId, required this.emoji});

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(userId: json['userId'], emoji: json['emoji']);
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'emoji': emoji};
  }
}

class VoiceMessage {
  final double duration;
  final List<double> waveform;

  VoiceMessage({required this.duration, required this.waveform});

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    return VoiceMessage(
      duration: json['duration'].toDouble(),
      waveform: List<double>.from(json['waveform']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'duration': duration, 'waveform': waveform};
  }
}

class Poll {
  final String question;
  final List<String> options;
  final List<PollVote> votes;
  final DateTime endDate;

  Poll({
    required this.question,
    required this.options,
    required this.votes,
    required this.endDate,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      question: json['question'],
      options: List<String>.from(json['options']),
      votes:
          (json['votes'] as List)
              .map((vote) => PollVote.fromJson(vote))
              .toList(),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'votes': votes.map((vote) => vote.toJson()).toList(),
      'endDate': endDate.toIso8601String(),
    };
  }
}

class PollVote {
  final int optionIndex;
  final String userId;

  PollVote({required this.optionIndex, required this.userId});

  factory PollVote.fromJson(Map<String, dynamic> json) {
    return PollVote(optionIndex: json['optionIndex'], userId: json['userId']);
  }

  Map<String, dynamic> toJson() {
    return {'optionIndex': optionIndex, 'userId': userId};
  }
}

class Contact {
  final int? id;
  final String? name;
  final String? email;
  final String? number;
  final String? profilePicUrl;
  final bool? ignoreMessages;

  Contact({
    this.id,
    this.name,
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

class Message {
  final String id;
  final String? body;
  final String? mediaType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? mediaName;
  final String? mediaSize;
  final String? mediaDuration;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final bool fromMe;
  final bool read;
  final bool delivered;
  final bool isDeleted;
  final bool isEdited;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Contact? contact;
  final int ticketId;
  final String? quotedMsgId;
  final Message? quotedMsg;
  final String? remoteJid;
  final String? participant;
  final int? ack;
  final String? dataJson;
  final String? type;
  final String? highlightedText;
  final List<String>? mentionedUsers;
  final LinkPreview? linkPreview;
  final List<Reaction>? reactions;
  final bool isPinned;
  final String? forwardedFrom;
  final VoiceMessage? voiceMessage;
  final Poll? poll;
  final String status;

  Message({
    required this.id,
    this.body,
    this.mediaType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mediaName,
    this.mediaSize,
    this.mediaDuration,
    this.locationName,
    this.latitude,
    this.longitude,
    required this.fromMe,
    required this.read,
    required this.delivered,
    required this.isDeleted,
    required this.isEdited,
    this.createdAt,
    this.updatedAt,
    this.contact,
    required this.ticketId,
    this.quotedMsgId,
    this.quotedMsg,
    this.remoteJid,
    this.participant,
    this.ack,
    this.dataJson,
    this.type,
    this.highlightedText,
    this.mentionedUsers,
    this.linkPreview,
    this.reactions,
    this.isPinned = false,
    this.forwardedFrom,
    this.voiceMessage,
    this.poll,
    this.status = 'SENT',
  });

  // Fungsi untuk mengekstrak tipe pesan dari dataJson
  String? get messageType {
    if (dataJson == null) return null;
    try {
      final data = json.decode(dataJson!);
      final message = data['message'];
      if (message == null) return null;

      // Cek tipe pesan dari properti yang ada di message
      if (message['conversation'] != null) return 'conversation';
      if (message['extendedTextMessage'] != null) return 'extendedTextMessage';
      if (message['imageMessage'] != null) return 'imageMessage';
      if (message['videoMessage'] != null) return 'videoMessage';
      if (message['audioMessage'] != null) return 'audioMessage';
      if (message['documentMessage'] != null) return 'documentMessage';
      if (message['documentWithCaptionMessage'] != null)
        return 'documentWithCaptionMessage';
      if (message['locationMessage'] != null) return 'locationMessage';
      if (message['contactMessage'] != null) return 'contactMessage';
      if (message['stickerMessage'] != null) return 'stickerMessage';
      if (message['buttonsResponseMessage'] != null)
        return 'buttonsResponseMessage';
      if (message['buttonsMessage'] != null) return 'buttonsMessage';
      if (message['listResponseMessage'] != null) return 'listResponseMessage';
      if (message['listMessage'] != null) return 'listMessage';
      if (message['viewOnceMessage'] != null) return 'viewOnceMessage';
      if (message['editedMessage'] != null) return 'editedMessage';
      if (message['reactionMessage'] != null) return 'reactionMessage';
      if (message['ephemeralMessage'] != null) return 'ephemeralMessage';
      if (message['protocolMessage'] != null) return 'protocolMessage';
      if (message['contactsArrayMessage'] != null)
        return 'contactsArrayMessage';
      if (message['liveLocationMessage'] != null) return 'liveLocationMessage';
      if (message['voiceMessage'] != null) return 'voiceMessage';
      if (message['mediaMessage'] != null) return 'mediaMessage';

      return null;
    } catch (e) {
      print('Error parsing dataJson: $e');
      return null;
    }
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      body: json['body'],
      mediaType: json['mediaType'],
      mediaUrl: json['mediaUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      mediaName: json['mediaName'],
      mediaSize: json['mediaSize'],
      mediaDuration: json['mediaDuration'],
      locationName: json['locationName'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      fromMe: json['fromMe'] ?? false,
      read: json['read'] ?? false,
      delivered: json['delivered'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      isEdited: json['isEdited'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      contact:
          json['contact'] != null ? Contact.fromJson(json['contact']) : null,
      ticketId: json['ticketId'] ?? 0,
      quotedMsgId: json['quotedMsgId'],
      quotedMsg:
          json['quotedMsg'] != null
              ? Message.fromJson(json['quotedMsg'])
              : null,
      remoteJid: json['remoteJid'],
      participant: json['participant'],
      ack: json['ack'],
      dataJson: json['dataJson'],
      type: json['type'],
      highlightedText: json['highlightedText'],
      mentionedUsers:
          json['mentionedUsers'] != null
              ? List<String>.from(json['mentionedUsers'])
              : null,
      linkPreview:
          json['linkPreview'] != null
              ? LinkPreview.fromJson(json['linkPreview'])
              : null,
      reactions:
          json['reactions'] != null
              ? (json['reactions'] as List)
                  .map((r) => Reaction.fromJson(r))
                  .toList()
              : null,
      isPinned: json['isPinned'] ?? false,
      forwardedFrom: json['forwardedFrom'],
      voiceMessage:
          json['voiceMessage'] != null
              ? VoiceMessage.fromJson(json['voiceMessage'])
              : null,
      poll: json['poll'] != null ? Poll.fromJson(json['poll']) : null,
      status: json['status'] ?? 'SENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediaName': mediaName,
      'mediaSize': mediaSize,
      'mediaDuration': mediaDuration,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'fromMe': fromMe,
      'read': read,
      'delivered': delivered,
      'isDeleted': isDeleted,
      'isEdited': isEdited,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'contact': contact?.toJson(),
      'ticketId': ticketId,
      'quotedMsgId': quotedMsgId,
      'quotedMsg': quotedMsg?.toJson(),
      'remoteJid': remoteJid,
      'participant': participant,
      'ack': ack,
      'dataJson': dataJson,
      'type': type,
      'highlightedText': highlightedText,
      'mentionedUsers': mentionedUsers,
      'linkPreview': linkPreview?.toJson(),
      'reactions': reactions?.map((r) => r.toJson()).toList(),
      'isPinned': isPinned,
      'forwardedFrom': forwardedFrom,
      'voiceMessage': voiceMessage?.toJson(),
      'poll': poll?.toJson(),
      'status': status,
    };
  }

  Message copyWith({
    String? id,
    String? body,
    String? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? mediaName,
    String? mediaSize,
    String? mediaDuration,
    String? locationName,
    double? latitude,
    double? longitude,
    bool? fromMe,
    bool? read,
    bool? delivered,
    bool? isDeleted,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    Contact? contact,
    int? ticketId,
    String? quotedMsgId,
    Message? quotedMsg,
    String? remoteJid,
    String? participant,
    int? ack,
    String? dataJson,
    String? type,
    String? highlightedText,
    List<String>? mentionedUsers,
    LinkPreview? linkPreview,
    List<Reaction>? reactions,
    bool? isPinned,
    String? forwardedFrom,
    VoiceMessage? voiceMessage,
    Poll? poll,
    String? status,
  }) {
    return Message(
      id: id ?? this.id,
      body: body ?? this.body,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaName: mediaName ?? this.mediaName,
      mediaSize: mediaSize ?? this.mediaSize,
      mediaDuration: mediaDuration ?? this.mediaDuration,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fromMe: fromMe ?? this.fromMe,
      read: read ?? this.read,
      delivered: delivered ?? this.delivered,
      isDeleted: isDeleted ?? this.isDeleted,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contact: contact ?? this.contact,
      ticketId: ticketId ?? this.ticketId,
      quotedMsgId: quotedMsgId ?? this.quotedMsgId,
      quotedMsg: quotedMsg ?? this.quotedMsg,
      remoteJid: remoteJid ?? this.remoteJid,
      participant: participant ?? this.participant,
      ack: ack ?? this.ack,
      dataJson: dataJson ?? this.dataJson,
      type: type ?? this.type,
      highlightedText: highlightedText ?? this.highlightedText,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      linkPreview: linkPreview ?? this.linkPreview,
      reactions: reactions ?? this.reactions,
      isPinned: isPinned ?? this.isPinned,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      voiceMessage: voiceMessage ?? this.voiceMessage,
      poll: poll ?? this.poll,
      status: status ?? this.status,
    );
  }
}
