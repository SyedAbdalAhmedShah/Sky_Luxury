import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';

class AgentHomeRepository {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future updateAgentBalance(String documentId, double balance) async {
    await firestore.collection(Strings.agentsColl).doc(documentId).set(
        {'balance': balance},
        SetOptions(merge: true)).then((value) => print('balance updated'));

    AgentManager.agent.balance = balance;
  }

  Future updateAgentTicker(String documentId, double ticket) async {
    await firestore.collection(Strings.agentsColl).doc(documentId).set(
        {'tickets': ticket.toDouble()},
        SetOptions(merge: true)).then((value) => print('balance updated'));

    AgentManager.agent.tickets = ticket.toString();
  }

  Future getAgentData(String docId) async {
    final doc = await firestore.collection(Strings.agentsColl).doc(docId).get();
    final agent = AgentModel.fromJson(doc.data()!);

    AgentManager.agent = agent;
  }
}
