import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_luxury/blocs/login_bloc/login_event.dart';
import 'package:sky_luxury/blocs/login_bloc/login_state.dart';
import 'package:sky_luxury/blocs/signup_bloc/signup_event.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/model/agent_model.dart';
import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/repository/login_repo.dart';
import 'package:sky_luxury/repository/signup_repo.dart';

import '../../manager/agent_manager.dart';

class LoginBloc extends Bloc<LoginEvents, LoginStates> {
  LoginRepository repository = LoginRepository();
  SignupRepository signrepository = SignupRepository();
  LoginBloc(InitialLoginEvent initialLoginEvent) : super(initialLoginEvent) {
    on<UserLoginEvent>((event, emit) async {
      emit(LoadingLoginEvent());
      try {
        UserCredential user = await repository.login(
            email: event.email, password: event.password);
        print(user);
        bool exist = await repository.isAgentExist(user.user!.uid);

        if (exist) {
          QuerySnapshot<Map<String, dynamic>> doc =
              await repository.getAgentById(user.user!.uid);

          final agent = AgentModel.fromJson(doc.docs.first.data());
          print('agent---------' + agent.toString());
          user.user!.emailVerified
              ? await repository.saveDataIntoShareprefrences(agent)
              : null;

          bool convoExsist = await repository.isConversationExistWithAdmin();
          print(convoExsist);
          if (convoExsist == false) {
            Conversation conversation = Conversation(
                agentId: user.user!.uid,
                timestamp: Timestamp.now(),
                username: AgentManager.agent.username,
                countForAdmin: 0,
                countForAgent: 0);
            await signrepository.createConversationWithAdmin(conversation);
          }
          emit(SuccessLoginEvent(authResult: user, isAdmin: false));
        } else {
          emit(FailureLoginEvent(message: Strings.noUserFound));
        }
      } catch (error) {
        print('login bloc error ' + error.toString());
        emit(FailureLoginEvent(message: error.toString()));
      }
    });
    on<AdminLoginEvent>((event, emit) async {
      emit(LoadingLoginEvent());
      try {
        UserCredential user = await repository.login(
            email: event.email, password: event.password);
        print(user);
        bool exist = await repository.isAgentExist(user.user!.uid);
        if (!exist) {
          await repository.storeAdminInformation(event.email, user.user!.uid);
          await repository.saveDataInSharePrefences(user.user!.uid);
          await repository.retriveDataAndStoreInManager();
          emit(SuccessLoginEvent(authResult: user, isAdmin: true));
        } else {
          emit(FailureLoginEvent(message: Strings.noadminFound));
        }
      } catch (error) {
        print('error occure in admin login' + error.toString());
        emit(FailureLoginEvent(message: error.toString()));
      }
    });

    on<ResetPasswordEvent>((event, emit) async {
      emit(LoadingLoginEvent());
      try {
        FirebaseAuth auth = FirebaseAuth.instance;
        String pattern =
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

        RegExp regExp = new RegExp(pattern);
        if (event.email != null && regExp.hasMatch(event.email)) {
          await auth.sendPasswordResetEmail(email: event.email);
          emit(ResetPasswordSuccessfully());
        }
      } catch (error) {
        print('error occur during reset password' + error.toString());
        FailureLoginEvent(message: error.toString());
      }
    });
  }
}
