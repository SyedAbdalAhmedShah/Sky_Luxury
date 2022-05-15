import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/model/message.dart';

abstract class ConversationStates {}

class InitialConversationState extends ConversationStates {}

class LoadingConversationState extends ConversationStates {}

class SuccessConversationState extends ConversationStates {
  Stream<List<Conversation>> conversation;
  SuccessConversationState({required this.conversation});
}

class GetMessages extends ConversationStates {
  Stream<List<Message>> messageStream;
  GetMessages({required this.messageStream});
}

class FailureConversationState extends ConversationStates {
  final String message;
  FailureConversationState({required this.message});
}

class DeletedConversationState extends ConversationStates {}
