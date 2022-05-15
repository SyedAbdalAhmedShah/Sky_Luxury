abstract class AgentHomeStates {}

class AgentHomeInitialState extends AgentHomeStates {}

class AgentHomeLoadingState extends AgentHomeStates {}

class UpdatedTicketsSuccessfully extends AgentHomeStates {}

class UpdatedBalanceSuccessfully extends AgentHomeStates {}

class AgentGetSuccessfully extends AgentHomeStates {}

class AgentHomeFailuteState extends AgentHomeStates {
  String error;
  AgentHomeFailuteState({required this.error});
}
