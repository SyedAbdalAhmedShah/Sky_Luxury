import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_state.dart';
import 'package:sky_luxury/blocs/agent_homeBloc/agent_home_event.dart';
import 'package:sky_luxury/blocs/agent_homeBloc/agent_home_state.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/repository/agent_home_repo.dart';

class AgentHomeBloc extends Bloc<AgentHomeEvents, AgentHomeStates> {
  AgentHomeRepository repo = AgentHomeRepository();
  AgentHomeBloc(AgentHomeInitialState initialState) : super(initialState) {
    on<UpdateBalanceEvent>((event, emit) async {
      emit(AgentHomeLoadingState());
      try {
        print('document id ' + AgentManager.agent.documentId.toString());
        await repo.updateAgentBalance(
            AgentManager.agent.documentId.toString(), event.balance);
        emit(UpdatedBalanceSuccessfully());
      } catch (error) {
        print('error occure while updating agent home balance ' +
            error.toString());
        emit(AgentHomeFailuteState(error: error.toString()));
      }
    });
    on<UpdateTicketsEvent>((event, emit) async {
      emit(AgentHomeLoadingState());
      try {
        print('document id ' + AgentManager.agent.documentId.toString());
        await repo.updateAgentTicker(
            AgentManager.agent.documentId.toString(), event.tickets);
        emit(UpdatedTicketsSuccessfully());
      } catch (error) {
        print('error occure while updating agent home balance ' +
            error.toString());
        emit(AgentHomeFailuteState(error: error.toString()));
      }
    });
    on<GetAgentDataByDocId>((event, emit) async {
      emit(AgentHomeLoadingState());

      try {
        await repo.getAgentData(event.documentId);
        emit(AgentGetSuccessfully());
      } catch (error) {
        print(error);
      }
    });
  }
}
