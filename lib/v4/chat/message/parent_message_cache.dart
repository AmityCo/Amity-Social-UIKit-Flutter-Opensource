import 'package:amity_sdk/amity_sdk.dart';

class ParentMessageCache {
  ParentMessageCache._internal();

  static final ParentMessageCache _instance = ParentMessageCache._internal();

  factory ParentMessageCache() => _instance;

  final Map<String, AmityMessage> _messages = {};

  void addMessage(String messageId, AmityMessage message) {
    _messages[messageId] = message;
  }

  AmityMessage? getMessage(String messageId) {
    return _messages[messageId];
  }

  bool containsMessage(String messageId) {
    return _messages.containsKey(messageId);
  }

  void updateMessageIfExists(String messageId, AmityMessage updatedMessage) {
    if (_messages.containsKey(messageId)) {
      _messages[messageId] = updatedMessage;
    }
  }

  void removeMessage(String messageId) {
    _messages.remove(messageId);
  }

  void clear() {
    _messages.clear();
  }
}
