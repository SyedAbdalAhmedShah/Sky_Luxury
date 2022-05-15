import 'package:sky_luxury/model/message.dart';

abstract class ChatStates {}

class InitialChatState extends ChatStates {}

class LoadingChatState extends ChatStates {}

class SuccessChatState extends ChatStates {
  Stream<List<Message>> message;
  SuccessChatState({required this.message});
}

class SendMessageSuccess extends ChatStates {}

class FailureChatState extends ChatStates {
  final String message;
  FailureChatState({required this.message});
}

class AttachmentUploadedState extends ChatStates {
  final String firebaseimage;
  AttachmentUploadedState({required this.firebaseimage});
}

class MessageDeletedState extends ChatStates {}

class NewConversationCreatedState extends ChatStates {
  final String conversationId;
  NewConversationCreatedState({required this.conversationId});
}

class ConversationAlreadyExistState extends ChatStates {
  final String conversationId;
  ConversationAlreadyExistState({required this.conversationId});
}
