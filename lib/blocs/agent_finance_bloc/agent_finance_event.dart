import 'package:sky_luxury/model/add_agent.dart';

abstract class AgentFinanceEvent {}

class AddFinanceAgentEvent extends AgentFinanceEvent {
  final AddAgent agent;
  final String imagePath;
  final String imageName;
  AddFinanceAgentEvent(
      {required this.agent, required this.imagePath, required this.imageName});
}

class GetAllFinanceAgentEvent extends AgentFinanceEvent {}

class UpdateBlanceEvent extends AgentFinanceEvent {
  final String docId;
  final double recievingBalance;
  final double totalBalance;
  final double remainingBalance;
  final int ticketQuantity;
  UpdateBlanceEvent(
      {required this.recievingBalance,
      required this.docId,
      required this.remainingBalance,
      required this.ticketQuantity,
      required this.totalBalance});
}

class DeleteAgent extends AgentFinanceEvent {
  final String docId;
  DeleteAgent({required this.docId});
}

class LogoutEvent extends AgentFinanceEvent {}

class AdminNameUpdateEvent extends AgentFinanceEvent {
  String adminName;
  AdminNameUpdateEvent({required this.adminName});
}
