import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/ai_chat_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  static final _welcomeMessage = ChatMessage(
    id: 'welcome',
    text:
        '¡Hola! Soy el asistente virtual de LifeTours. Puedes preguntarme sobre tours, reservas, destinos, pagos o cualquier otra duda que tengas. ¿En qué puedo ayudarte?',
    isUser: false,
  );

  ChatProvider() {
    _messages.add(_welcomeMessage);
  }

  Future<void> sendMessage(
    String text, {
    List<DestinationModel>? destinations,
    List<TourModel>? tours,
  }) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text.trim(),
      isUser: true,
    );
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    final reply = await AiChatService.sendMessage(
      text.trim(),
      destinations: destinations,
      tours: tours,
    );

    final botMsg = ChatMessage(
      id: const Uuid().v4(),
      text: reply,
      isUser: false,
    );
    _messages.add(botMsg);
    _isLoading = false;
    notifyListeners();
  }
}
