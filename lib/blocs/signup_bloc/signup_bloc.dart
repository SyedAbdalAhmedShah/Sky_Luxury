import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_luxury/blocs/signup_bloc/signup_event.dart';
import 'package:sky_luxury/blocs/signup_bloc/signup_state.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';
import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/repository/signup_repo.dart';

class SignupBloc extends Bloc<SignupEvent, SignupStates> {
  SignupRepository repository = SignupRepository();
  SignupBloc(InitialSignupState initialSignupState)
      : super(initialSignupState) {
    on<UserSignupEvent>((event, emit) async {
      emit(LoadingSignupState());
      try {
        UserCredential userCredential = await repository.signup(
            password: event.password, email: event.email);

        userCredential.user?.sendEmailVerification();
        AgentModel agent = AgentModel(
          username: event.userName,
          userID: userCredential.user!.uid,
          email: userCredential.user!.email,
        );
        await repository.saveDataIntoDB(agent);
        Conversation conversation = Conversation(
            agentId: userCredential.user!.uid,
            timestamp: Timestamp.now(),
            username: AgentManager.agent.username,
            countForAdmin: 0,
            countForAgent: 0);
        await repository.createConversationWithAdmin(conversation);
        emit(SuccessSignupState());
      } catch (error) {
        print('signup error ' + error.toString());
        emit(FailureSignupState(message: error.toString()));
      }
    });
  }
}
