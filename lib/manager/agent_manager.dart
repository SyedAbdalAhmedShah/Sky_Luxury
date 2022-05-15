import 'package:sky_luxury/model/agent_model.dart';

class AgentManager {
  AgentManager._privateConstructor();

  static AgentModel agent = AgentModel();
  static bool isAgnetLogedIn = false;
  static final AgentManager _instance = AgentManager._privateConstructor();

  factory AgentManager() {
    return _instance;
  }
}
