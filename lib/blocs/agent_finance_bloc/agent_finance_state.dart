import 'package:sky_luxury/model/add_agent.dart';
import 'package:sky_luxury/model/message.dart';

abstract class AgentFinanceStates {}

class InitialFinanceState extends AgentFinanceStates {}

class LoadingFetchingFinanceState extends AgentFinanceStates {}

class SuccessGetFinanceState extends AgentFinanceStates {
  Stream<List<AddAgent>> agents;
  SuccessGetFinanceState({required this.agents});
}

class SuccessAddedFinanceAgentState extends AgentFinanceStates {}

class UpdatedBalanceState extends AgentFinanceStates {
  final AddAgent finance;
  UpdatedBalanceState({required this.finance});
}

class DeletedState extends AgentFinanceStates {}

class LogoutState extends AgentFinanceStates {}

class FailureFinanceState extends AgentFinanceStates {
  final String message;
  FailureFinanceState({required this.message});
}

class AdminNameUpdatedSuccessfull extends AgentFinanceStates {}

class AdminNameFailureState extends AgentFinanceStates {
  final String error;
  AdminNameFailureState({required this.error});
}
