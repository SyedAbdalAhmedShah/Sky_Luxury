import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sky_luxury/components/strings.dart';

class Conversation {
  String? username;
  Timestamp? timestamp;
  String? conversationId;
  String? agentId;
  String? targetUserID;
  String? lastMessage;
  int? countForAdmin;
  int? countForAgent;

  Conversation(
      {this.username,
      this.timestamp,
      this.conversationId,
      this.agentId,
      this.lastMessage,
      this.countForAdmin,
      this.countForAgent,
      this.targetUserID});

  Conversation.fromJson(Map<String, dynamic> json) {
    username = json[Strings.userName];
    timestamp = json[Strings.timeStamp];
    conversationId = json[Strings.conversationId];
    agentId = json[Strings.agentId];
    targetUserID = json[Strings.targetUserId];
    countForAdmin = json[Strings.countForAdmin];
    countForAgent = json[Strings.countForAgent];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[Strings.userName] = this.username;
    data[Strings.timeStamp] = this.timestamp;
    data[Strings.conversationId] = this.conversationId;
    data[Strings.agentId] = this.agentId;
    data[Strings.targetUserId] = this.targetUserID;
    data[Strings.countForAdmin] = this.countForAdmin;
    data[Strings.countForAgent] = this.countForAgent;
    return data;
  }
}
