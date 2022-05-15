import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';

class LoginRepository {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<UserCredential> login(
      {required String email, required String password}) async {
    UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return userCredential;
  }

  Future<bool> isAgentExist(String userId) async {
    QuerySnapshot<Map<String, dynamic>> query = await firestore
        .collection(Strings.agentsColl)
        .where(Strings.userID, isEqualTo: userId)
        .get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> doc = query.docs;

    if (doc.length > 0) {
      print('agent found');
      return true;
    } else {
      return false;
    }
  }

  Future saveDataIntoShareprefrences(AgentModel agentModel) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    DocumentReference<Map<String, dynamic>> docRef =
        firestore.collection(Strings.agentsColl).doc();

    final isLogedIn =
        await sharedPreferences.setBool(Strings.agentIsLogedIn, true);
    sharedPreferences.setString(
        Strings.agentKey, json.encode(agentModel.toJson()));
    AgentManager.agent = agentModel;

    AgentManager.isAgnetLogedIn = isLogedIn;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAgentById(String uid) async {
    QuerySnapshot<Map<String, dynamic>> patient = await firestore
        .collection(Strings.agentsColl)
        .where(Strings.userID, isEqualTo: uid)
        .get();
    return patient;
  }

  storeAdminInformation(String email, String uid) async {
    Map<String, dynamic> data = Map<String, dynamic>();
    data[Strings.email] = email;
    data[Strings.userID] = uid;
    DocumentReference<Map<String, dynamic>> doc =
        firestore.collection(Strings.adminColl).doc();
    bool exisit = await isAlreadyStore(uid);
    if (!exisit) {
      print('admin record not exist');
      doc.set(data).then((value) => print('record saved successfully'));
    } else {
      print('admin record exis no need to store data');
    }
  }

  Future<bool> isAlreadyStore(String uid) async {
    QuerySnapshot<Map<String, dynamic>> qs = await firestore
        .collection(Strings.adminColl)
        .where(Strings.userID, isEqualTo: uid)
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> doc = qs.docs;
    if (doc.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future saveDataInSharePrefences(String uid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(Strings.adminKey, true).then((value) =>
        print('admin stored in shredPrefreces:  ' + value.toString()));
    await sharedPreferences.setString(Strings.adminUid, uid);
    AdminManager.adminUid = uid;
  }

  Future<bool> isConversationExistWithAdmin() async {
    QuerySnapshot<Map<String, dynamic>> admindoc =
        await firestore.collection(Strings.adminColl).get();
    var docs = admindoc.docs.first;
    String adminUid = docs.get(Strings.userID);
    CollectionReference<Map<String, dynamic>> collection =
        await firestore.collection(Strings.conversationColl);
    QuerySnapshot<Map<String, dynamic>> doc = await collection.get();
    print(doc.docs.length);
    if (doc.docs.length > 0) {
      QuerySnapshot<Map<String, dynamic>> qshot = await collection
          .where(Strings.targetUserId, isEqualTo: adminUid)
          .where(Strings.agentId, isEqualTo: AgentManager.agent.userID)
          .get();
      if (qshot.docs.length > 0) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future retriveDataAndStoreInManager() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    AdminManager.isAdminLogedIn =
        await preferences.containsKey(Strings.adminKey);
    AdminManager.adminUid = await preferences.getString(Strings.adminUid) ?? '';
    AdminManager.adminName =
        await preferences.getString(Strings.adminName) ?? '';
    print('Admin uid' + AdminManager.adminUid);
  }
}
