import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sky_luxury/components/strings.dart';

class Message {
  String? messageId;
  String? conversationId;
  String? description;
  Timestamp? timestamp;
  String? userName;
  String? userId;
  String? targetUserId;
  String? type;

  Message(
      {this.userId,
      this.targetUserId,
      this.userName,
      this.conversationId,
      this.messageId,
      this.timestamp,
      this.type,
      this.description});

  factory Message.formJson(Map<String, dynamic> json) => Message(
      messageId: json[Strings.messageId],
      timestamp: json[Strings.timeStamp],
      conversationId: json[Strings.conversationId],
      userName: json[Strings.userName],
      type: json[Strings.type],
      description: json[Strings.description],
      targetUserId: json[Strings.targetUserId],
      userId: json[Strings.userID]);

  Map<String, dynamic> toJson() => {
        Strings.messageId: messageId,
        Strings.description: description,
        Strings.userName: userName,
        Strings.timeStamp: timestamp,
        Strings.type: type,
        Strings.conversationId: conversationId,
        Strings.userID: userId,
        Strings.targetUserId: targetUserId
      };
}
