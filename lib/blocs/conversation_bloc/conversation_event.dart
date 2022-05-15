abstract class ConversationEvents {}

class ConversationById extends ConversationEvents {}

class GetMessageById extends ConversationEvents {
  final String conversationId;
  GetMessageById({required this.conversationId});
}

class DeleteConversationEvent extends ConversationEvents {
  final String conversationId;
  DeleteConversationEvent({required this.conversationId});
}
