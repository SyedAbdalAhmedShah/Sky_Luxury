import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/model/message.dart';

class ChatRepository {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessage(String conversationId) {
    Stream<QuerySnapshot<Map<String, dynamic>>> qs = firestore
        .collection(Strings.messagesColl)
        .where(Strings.conversationId, isEqualTo: conversationId)
        .orderBy(Strings.timeStamp, descending: true)
        .snapshots();
    return qs.map((event) => event.docs.map((eV) {
          Message message = Message();
          try {
            message = Message.formJson(eV.data());
          } catch (error) {
            print('error occure during send message' + error.toString());
          }
          return message;
        }).toList());
  }

  Future sendMessages(Message message, String conversationId) async {
    print('convooooo id ------- ' + message.conversationId.toString());
    DocumentReference<Map<String, dynamic>> collection =
        await firestore.collection(Strings.messagesColl).doc();
    message.messageId = collection.id;
    message.conversationId = conversationId;
    updateConversationTime(conversationId);
    countMessages(conversationId);
    await collection
        .set(message.toJson())
        .then((value) => print('message send'));
  }

  updateConversationTime(String docId) async {
    Map<String, dynamic> mapData = Map<String, dynamic>();
    DocumentReference<Map<String, dynamic>> doc =
        await firestore.collection(Strings.conversationColl).doc(docId);
    mapData[Strings.timeStamp] = Timestamp.now();
    await doc.update(mapData).then((value) => print('latest Date Updated  '));
  }

  countIncreaseInAdminCollection(String id) async {
    var collection = await firestore.collection(Strings.adminColl).get();
    var doc = collection.docs.first;

    // print('id---------' + collection.id);

    int count = doc.get(Strings.count);
    count += 1;
    doc.reference
        .update({'count': count}).then((value) => print('document updated'));
  }

  Future countMessages(String docId) async {
    var collection =
        await firestore.collection(Strings.conversationColl).doc(docId);
    var doc = await collection.get();
    int adminCount = doc.get(Strings.countForAdmin);
    int agentCount = doc.get(Strings.countForAgent);
    Map<String, dynamic> updateCounts = Map<String, dynamic>();
    if (AgentManager.isAgnetLogedIn) {
      adminCount += 1;
      updateCounts[Strings.countForAdmin] = adminCount;
    } else {
      agentCount += 1;
      updateCounts[Strings.countForAgent] = agentCount;
    }
    await collection
        .update(updateCounts)
        .then((value) => print('messages count updated'));
  }

  Future unCoundMessages(String docId) async {
    var collection =
        await firestore.collection(Strings.conversationColl).doc(docId);
    var doc = await collection.get();
    int adminCount = doc.get(Strings.countForAdmin);
    int agentCount = doc.get(Strings.countForAgent);
    Map<String, dynamic> updateCounts = Map<String, dynamic>();
    if (AgentManager.isAgnetLogedIn) {
      agentCount = 0;
      updateCounts[Strings.countForAgent] = agentCount;
    } else {
      adminCount = 0;
      updateCounts[Strings.countForAdmin] = adminCount;
    }
    await collection
        .update(updateCounts)
        .then((value) => print('messages count updated'));
  }

  Future<String> compressFile(String imagePath) async {
    String targetPath = join((await getTemporaryDirectory()).path,
        '${DateTime.now()}.${extension(imagePath)}');
    File? result = await FlutterImageCompress.compressAndGetFile(
        imagePath, targetPath,
        quality: 60);

    print('result size ' + result!.lengthSync().toString());
    print('target path ' + targetPath);
    print('path' + result.path);
    return result.path;
  }

  Future uploadImage(
      {required String imageName, required String imagePath}) async {
    print('image name ' + imageName);
    FirebaseStorage storage = FirebaseStorage.instance;
    String firebaseImagePath = '';
    final refrence =
        storage.ref().child(Strings.chatAttachment).child(imageName);

    UploadTask uploadTask = refrence.putFile(File(imagePath));

    print('user image url ======== ${uploadTask.storage.bucket}');
    final tasksnapshot = await uploadTask.whenComplete(() async {
      final imageurl = await storage
          .ref()
          .child(Strings.chatAttachment)
          .child(imageName)
          .getDownloadURL();

      // print('image url...........$imageurl');

      // return imageurl;
      firebaseImagePath = imageurl;
    });
    print('firebase image path ' + firebaseImagePath);
    return firebaseImagePath;
  }

  Future deleteMessage(String messageId) async {
    await firestore
        .collection(Strings.messagesColl)
        .doc(messageId)
        .delete()
        .then((value) => print('message deleted'));
  }

  Future<String> creatConvoAndSendMessage(Conversation conversation) async {
    DocumentReference<Map<String, dynamic>> collection =
        firestore.collection(Strings.conversationColl).doc();
    conversation.conversationId = collection.id;
    await collection
        .set(conversation.toJson())
        .then((value) => print('conversation createdd by search'));

    return collection.id;
    // await sendMessages(message, collection.id);
  }

  Future<String> isAlreadyExsistConversation(Conversation conversation) async {
    final collection = await firestore
        .collection(Strings.conversationColl)
        .where(Strings.agentId, isEqualTo: conversation.agentId)
        .where(Strings.targetUserId, isEqualTo: conversation.targetUserID)
        .get();
    final conversationId = collection.docChanges.first.doc.id;
    print('conversation id exisit ' + conversationId);
    return conversationId;
  }
}
