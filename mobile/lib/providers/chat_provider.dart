import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setMessages(List<Message> messages) {
    _messages = messages;
    notifyListeners();
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void updateMessage(Message updatedMessage) {
    final index = _messages.indexWhere((msg) => msg.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  void deleteMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void pinMessage(String messageId) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      _messages[index] = message.copyWith(isPinned: !message.isPinned);
      notifyListeners();
    }
  }

  void addReaction(String messageId, Reaction reaction) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      final reactions = [...?message.reactions, reaction];
      _messages[index] = message.copyWith(reactions: reactions);
      notifyListeners();
    }
  }

  void removeReaction(String messageId, String userId) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      final reactions =
          message.reactions?.where((r) => r.userId != userId).toList();
      _messages[index] = message.copyWith(reactions: reactions);
      notifyListeners();
    }
  }

  void forwardMessage(Message message, String targetChatId) {
    // TODO: Implement message forwarding logic
    notifyListeners();
  }

  void editMessage(String messageId, String newBody) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      _messages[index] = message.copyWith(body: newBody, isEdited: true);
      notifyListeners();
    }
  }

  void markAsRead(String messageId) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      final message = _messages[index];
      _messages[index] = message.copyWith(read: true);
      notifyListeners();
    }
  }
}
