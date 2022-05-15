import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:sky_luxury/blocs/chat_bloc/chat_events.dart';
import 'package:sky_luxury/blocs/chat_bloc/chat_states.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/message.dart';
import 'package:sky_luxury/repository/chat_repo.dart';

class ChatBloc extends Bloc<ChatEvents, ChatStates> {
  ChatRepository repository = ChatRepository();
  ChatBloc(InitialChatState initialChatState) : super(initialChatState) {
    on<GetMessageById>((event, emit) async {
      emit(LoadingChatState());
      try {
        Stream<List<Message>> message =
            repository.getMessage(event.conversationId);
        await repository.unCoundMessages(event.conversationId);

        emit(SuccessChatState(message: message));
      } catch (error) {
        print('send message event' + error.toString());
        emit(FailureChatState(message: error.toString()));
      }
    });

    on<SendMessageEvent>((event, emit) async {
      emit(LoadingChatState());
      try {
        print('target id ----' + event.message.targetUserId.toString());
        await repository.sendMessages(event.message, event.conversationId);
        if (AgentManager.isAgnetLogedIn) {
          await repository.countIncreaseInAdminCollection(
              event.message.targetUserId.toString());
        } else {}

        emit(SendMessageSuccess());
      } catch (error) {
        print('send message event' + error.toString());
        emit(FailureChatState(message: error.toString()));
      }
    });

    on<AttachmentSendEvent>((event, emit) async {
      emit(LoadingChatState());
      try {
        print('image appapa' + event.imagePath);
        final compressImage = await repository.compressFile(event.imagePath);
        final firebaseImagePath = await repository.uploadImage(
            imageName: event.imageName, imagePath: compressImage);
        emit(AttachmentUploadedState(firebaseimage: firebaseImagePath));
      } catch (error) {
        print('error during uploading image' + error.toString());
      }
    });
    on<MessageDeleteEvent>((event, emit) async {
      emit(LoadingChatState());
      try {
        await repository.deleteMessage(event.messageId);
        emit(MessageDeletedState());
      } catch (error) {
        print('error occure during  message deletion' + error.toString());
        FailureChatState(message: error.toString());
      }
    });

    on<CreateConversationAndSendMessage>((event, emit) async {
      emit(LoadingChatState());
      try {
        String conversationId = await repository.creatConvoAndSendMessage(
          event.conversation,
        );
        event.message.conversationId = conversationId;
        await repository.sendMessages(event.message, conversationId);
        emit(NewConversationCreatedState(conversationId: conversationId));
      } catch (error) {
        print('error occure create and sendig message ' + error.toString());
        FailureChatState(message: error.toString());
      }
    });
    on<IsConversationAlreadyExisit>((event, emit) async {
      emit(LoadingChatState());
      try {
        final conversationId =
            await repository.isAlreadyExsistConversation(event.conversation);
        emit(ConversationAlreadyExistState(conversationId: conversationId));
      } catch (error) {
        print('error occure ' + error.toString());
      }
    });
  }
}
