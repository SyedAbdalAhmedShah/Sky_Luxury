import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';
import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/repository/chat_repo.dart';

import '../model/message.dart';

class ConversationRepo {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  ChatRepository chatRepository = ChatRepository();

  Stream<List<Conversation>> getConversationById(String uid) {
    print('$uid');
    CollectionReference<Map<String, dynamic>> messg =
        firestore.collection(Strings.messagesColl);

    Query<Map<String, dynamic>> query = firestore
        .collection(Strings.conversationColl)
        .where(
            AgentManager.isAgnetLogedIn
                ? Strings.agentId
                : Strings.targetUserId,
            isEqualTo: uid)
        .orderBy(Strings.timeStamp, descending: true);

    Stream<QuerySnapshot<Map<String, dynamic>>> qShot = query.snapshots();

    return qShot.map((event) => event.docs.map((e) {
          Conversation conversation = Conversation.fromJson(e.data());
          print('conversationid' + conversation.conversationId.toString());

          Stream<List<Message>> message = firestore
              .collection(Strings.messagesColl)
              .where(Strings.conversationId,
                  isEqualTo: conversation.conversationId)
              .orderBy(Strings.timeStamp, descending: true)
              .snapshots()
              .map((mevent) =>
                  mevent.docs.map((e) => Message.formJson(e.data())).toList());
          message.listen((event) {
            if (event.isNotEmpty && event != null) {
              conversation.lastMessage = event.first.type == Strings.attachment
                  ? Strings.picture
                  : event.first.description ?? Strings.noMessage;
            } else {
              conversation.lastMessage = Strings.noMessageYet;
            }
          });
          return conversation;
        }).toList());
  }

  Future conversationDelete(String convoId) async {
    await firestore
        .collection(Strings.conversationColl)
        .doc(convoId)
        .delete()
        .then((value) => print('conversation deleted'));
  }

  Future<List<AgentModel>> searchAgent(String query) async {
    // QuerySnapshot<Map<String, dynamic>> qShot = await firestore
    //     .collection(Strings.agentsColl)
    //     .where(Strings.userName.toLowerCase(), is)
    //     .get();

    // List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = qShot.docs;
    // print(qShot.docs.contains(query));

    QuerySnapshot<Map<String, dynamic>> qShot =
        await firestore.collection(Strings.agentsColl).get();

    return qShot.docs
        .map((e) => AgentModel.fromJson(e.data()))
        .where((element) =>
            element.username?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
  }
}
