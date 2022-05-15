import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/model/message.dart';

abstract class ChatEvents {}

class SendMessageEvent extends ChatEvents {
  final Message message;
  final String conversationId;
  SendMessageEvent({required this.message, required this.conversationId});
}

class GetMessageById extends ChatEvents {
  final String conversationId;
  GetMessageById({required this.conversationId});
}

class MessageCounts extends ChatEvents {
  final String conversationId;
  MessageCounts({required this.conversationId});
}

class AttachmentSendEvent extends ChatEvents {
  final String imagePath;
  final String imageName;
  AttachmentSendEvent({required this.imagePath, required this.imageName});
}

class MessageDeleteEvent extends ChatEvents {
  final String messageId;
  MessageDeleteEvent({required this.messageId});
}

class CreateConversationAndSendMessage extends ChatEvents {
  final Message message;
  final Conversation conversation;
  CreateConversationAndSendMessage(
      {required this.message, required this.conversation});
}

class IsConversationAlreadyExisit extends ChatEvents {
  final Conversation conversation;
  IsConversationAlreadyExisit({required this.conversation});
}
