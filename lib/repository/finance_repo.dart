import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/model/add_agent.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FinanceRepo {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future addAgent(AddAgent agent) async {
    DocumentReference<Map<String, dynamic>> ds =
        await firestore.collection(Strings.financeColl).doc();
    agent.docid = ds.id;

    await ds
        .set(agent.toJson())
        .then((value) => print('inserted data successfully'));
  }

  Future<String> uploadImage(
      {required String imageName, required String imagePath}) async {
    String image = '';

    final refrence = storage.ref().child('agents').child(imageName);

    UploadTask uploadTask = refrence.putFile(File(imagePath));

    print('user image url ======== ${uploadTask.storage.bucket}');
    await uploadTask.whenComplete(() async {
      final imageurl =
          await storage.ref().child('agents').child(imageName).getDownloadURL();
      image = imageurl;
    });
    return image;
  }

  Stream<List<AddAgent>> getAllAgents() {
    AddAgent agent = AddAgent();
    print('stream');
    Stream<QuerySnapshot<Map<String, dynamic>>> snapshot = firestore
        .collection(Strings.financeColl)
        .orderBy(Strings.dateTime, descending: true)
        .snapshots();

    return snapshot.map((snap) => snap.docs.map((e) {
          print(e.data());

          agent = AddAgent.fromJson(e.data());
          print('agenttss-----' + agent.toString());

          return agent;
        }).toList());
  }

  Future<AddAgent> updateBalance(String docId, double recievingBalance,
      double totalBalance, double remainingBalance, int quantity) async {
    DocumentReference<Map<String, dynamic>> doc =
        await firestore.collection(Strings.financeColl).doc(docId);
    Map<String, dynamic> docUpdate = Map<String, dynamic>();
    docUpdate[Strings.quantity] = quantity;
    // if (totalBalance == 0.0) {
    //   docUpdate[Strings.remainingBal] = balance;
    //   docUpdate[Strings.totalBal] = balance;
    //   await doc.update(docUpdate).then((value) => print('balance updated'));
    // }
    // if (remainingBalance != 0.0) {
    //   double remainBalance = remainingBalance - balance;
    //   docUpdate[Strings.remainingBal] = remainBalance;
    //   await doc.update(docUpdate).then((value) => print('balance updated'));
    // }
    // if (remainingBalance == 0.0 && totalBalance > 0.0) {
    //   docUpdate[Strings.totalBal] = 0.0;
    //   await doc.update(docUpdate).then((value) => print('balance updated'));
    // }

    docUpdate[Strings.totalBal] = totalBalance;
    docUpdate[Strings.recievingBalance] = recievingBalance;
    docUpdate[Strings.remainingBal] = totalBalance - recievingBalance;
    await doc.update(docUpdate).then((value) => print('balance updated'));
    final data = await doc.get();
    AddAgent agentData = AddAgent.fromJson(data.data()!);
    return agentData;
  }

  Future<bool> deleteAgent(String docId) async {
    DocumentReference<Map<String, dynamic>> doc =
        await firestore.collection(Strings.financeColl).doc(docId);

    await doc.delete().then((value) => print('agent deleted'));
    return true;
  }

  Future logoutAdmin() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await auth.signOut().then((value) => print('lougout'));
    await preferences.clear();
    AdminManager.adminName = '';
    AdminManager.adminUid = '';
    AdminManager.isAdminLogedIn = false;
  }

  Future updateAdminName(String name) async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref
        .setString(Strings.adminName, name)
        .then((value) => print('admin name updated successfully $value'));
    AdminManager.adminName = name;
  }
}
