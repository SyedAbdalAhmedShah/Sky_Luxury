abstract class AgentHomeEvents {}

class UpdateTicketsEvent extends AgentHomeEvents {
  final double tickets;
  UpdateTicketsEvent({required this.tickets});
}

class UpdateBalanceEvent extends AgentHomeEvents {
  final double balance;
  UpdateBalanceEvent({required this.balance});
}

class GetAgentDataByDocId extends AgentHomeEvents {
  final String documentId;

  GetAgentDataByDocId({required this.documentId});
}
