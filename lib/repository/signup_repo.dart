import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';
import 'package:sky_luxury/model/conversation.dart';

class SignupRepository {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<UserCredential> signup(
      {required String password, required String email}) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      print('user credentials' + userCredential.toString());
      return userCredential;
    } catch (error) {
      print('error occure in signup' + error.toString());
      throw error;
    }
  }

  Future saveDataIntoDB(AgentModel agentModel) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> doc = Map<String, dynamic>();

    DocumentReference<Map<String, dynamic>> docRef =
        firestore.collection(Strings.agentsColl).doc();

    final isLogedIn =
        await sharedPreferences.setBool(Strings.agentIsLogedIn, true);
    agentModel.documentId = docRef.id;
    agentModel.balance = 0;
    agentModel.tickets = 0.toString();
    sharedPreferences.setString(
        Strings.agentKey, json.encode(agentModel.toJson()));

    AgentManager.agent = agentModel;

    AgentManager.isAgnetLogedIn = isLogedIn;

    docRef.set(agentModel.toJson());
  }

  createConversationWithAdmin(Conversation conversation) async {
    QuerySnapshot<Map<String, dynamic>> doc =
        await firestore.collection(Strings.adminColl).get();
    var docs = doc.docs.first;
    String adminUid = docs.get(Strings.userID);
    print('admin uid' + adminUid);
    DocumentReference conDoc =
        firestore.collection(Strings.conversationColl).doc();
    conversation.targetUserID = adminUid;
    conversation.conversationId = conDoc.id;

    conDoc.set(conversation.toJson()).then(
          (value) => print('conversation Maked successfully'),
        );
  }
}
