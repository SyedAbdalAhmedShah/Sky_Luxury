import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_event.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_state.dart';
import 'package:sky_luxury/model/add_agent.dart';
import 'package:sky_luxury/repository/finance_repo.dart';

class AgentFinanceBloc extends Bloc<AgentFinanceEvent, AgentFinanceStates> {
  FinanceRepo repo = FinanceRepo();
  AgentFinanceBloc(InitialFinanceState financeState) : super(financeState) {
    on<AddFinanceAgentEvent>((event, emit) async {
      emit(LoadingFetchingFinanceState());
      try {
        if (event.imageName.isNotEmpty || event.imagePath.isNotEmpty) {
          String imagePath = await repo.uploadImage(
              imageName: event.imageName, imagePath: event.imagePath);
          event.agent.profileImage = imagePath;
        } else {}

        await repo.addAgent(event.agent);

        emit(SuccessAddedFinanceAgentState());
      } catch (error) {
        print('error occure Add agent finance event ' + error.toString());
        FailureFinanceState(message: error.toString());
      }
    });

    on<GetAllFinanceAgentEvent>((event, emit) {
      emit(LoadingFetchingFinanceState());
      try {
        Stream<List<AddAgent>> agentsSnapShot = repo.getAllAgents();
        agentsSnapShot.first.catchError((error) {
          print('error occure' + error.toString());
        });
        emit(SuccessGetFinanceState(agents: agentsSnapShot));
      } catch (error) {
        print('error occure in get finance agent' + error.toString());
        emit(FailureFinanceState(message: error.toString()));
      }
    });

    on<UpdateBlanceEvent>((event, emit) async {
      emit(LoadingFetchingFinanceState());

      try {
        AddAgent agentData = await repo.updateBalance(
            event.docId,
            event.recievingBalance,
            event.totalBalance,
            event.remainingBalance,
            event.ticketQuantity);

        emit(UpdatedBalanceState(finance: agentData));
      } catch (error) {
        print('update balace error occure' + error.toString());
        emit(FailureFinanceState(message: error.toString()));
      }
    });
    on<DeleteAgent>((event, emit) async {
      emit(LoadingFetchingFinanceState());
      try {
        await Future.delayed(Duration(seconds: 1));
        bool isDeleted = await repo.deleteAgent(event.docId);
        if (isDeleted) {
          emit(DeletedState());
        }
        FailureFinanceState(message: 'Agent Does not deleted');
      } catch (error) {
        print('error occure during deletion' + error.toString());
        emit(FailureFinanceState(message: error.toString()));
      }
    });
    on<LogoutEvent>((event, emit) async {
      emit(LoadingFetchingFinanceState());
      try {
        await repo.logoutAdmin();
        emit(LogoutState());
      } catch (error) {
        print('error occure during logout' + error.toString());
        emit(FailureFinanceState(message: error.toString()));
      }
    });
    on<AdminNameUpdateEvent>((event, emit) async {
      emit(LoadingFetchingFinanceState());
      try {
        await repo.updateAdminName(event.adminName);
        emit(AdminNameUpdatedSuccessfull());
      } catch (error) {
        print('error occure during update admin name ' + error.toString());
        emit(AdminNameFailureState(error: error.toString()));
      }
    });
  }
}
