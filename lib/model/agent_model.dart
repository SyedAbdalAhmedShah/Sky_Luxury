import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sky_luxury/components/strings.dart';

class AgentModel {
  String? documentId;
  final String? username;
  final String? email;
  final String? userID;
  String? tickets;
  double? balance;

  AgentModel(
      {this.username,
      this.email,
      this.userID,
      this.tickets,
      this.balance,
      this.documentId});

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
        username: json[Strings.userName],
        documentId: json[Strings.documentId],
        email: json[Strings.email],
        userID: json[Strings.userID],
        tickets: json[Strings.tickets].toString(),
        balance: json[Strings.balance]);
  }

  Map<String, dynamic> toJson() {
    return {
      Strings.userName: this.username,
      Strings.documentId: this.documentId,
      Strings.email: this.email,
      Strings.userID: this.userID,
      Strings.tickets: this.tickets,
      Strings.balance: this.balance
    };
  }
}
