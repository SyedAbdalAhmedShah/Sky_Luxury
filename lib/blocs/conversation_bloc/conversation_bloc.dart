import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_luxury/blocs/conversation_bloc/conversation_event.dart';
import 'package:sky_luxury/blocs/conversation_bloc/conversation_state.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/message.dart';
import 'package:sky_luxury/repository/chat_repo.dart';
import 'package:sky_luxury/repository/conversation_repo.dart';

import '../../model/conversation.dart';

class ConversationBloc extends Bloc<ConversationEvents, ConversationStates> {
  ChatRepository chatRepository = ChatRepository();
  ConversationRepo repo = ConversationRepo();
  ConversationBloc(InitialConversationState initialConversationState)
      : super(initialConversationState) {
    on<ConversationById>((event, emit) async {
      emit(LoadingConversationState());
      try {
        String id = AgentManager.isAgnetLogedIn
            ? AgentManager.agent.userID!
            : AdminManager.adminUid;
        print('id------' + id.toString());
        Stream<List<Conversation>> conversation = repo.getConversationById(id);

        emit(SuccessConversationState(conversation: conversation));
      } catch (error) {
        print('error occure in conversation bloc ' + error.toString());
        FailureConversationState(message: error.toString());
      }
    });

    on<GetMessageById>((event, emit) {
      try {
        Stream<List<Message>> stream =
            chatRepository.getMessage(event.conversationId);
        GetMessages(messageStream: stream);
      } catch (e) {
        print("-------------" + e.toString());
      }
    });

    on<DeleteConversationEvent>((event, emit) async {
      // emit(LoadingConversationState());
      try {
        await repo.conversationDelete(event.conversationId);
        emit(DeletedConversationState());
      } catch (error) {
        print('error occure during conversation delete' + error.toString());
        FailureConversationState(message: error.toString());
      }
    });
  }
}
