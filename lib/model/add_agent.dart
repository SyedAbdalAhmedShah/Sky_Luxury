import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sky_luxury/components/strings.dart';

class AddAgent {
  String? docid;
  String? profileImage;
  String? name;
  int? ticketQuantity;
  String? email;
  String? phoneNumber;
  String? address;
  double? totalBalance;
  double? revievingBalance;
  double? remainingBalance;
  Timestamp? dateTime;

  AddAgent({
    this.docid,
    this.address,
    this.profileImage,
    this.email,
    this.ticketQuantity,
    this.name,
    this.phoneNumber,
    this.totalBalance,
    this.remainingBalance,
    this.revievingBalance,
    this.dateTime,
  });

  factory AddAgent.fromJson(Map<String, dynamic> json) => AddAgent(
      docid: json[Strings.documentId],
      email: json[Strings.email],
      profileImage: json[Strings.profileImage],
      address: json[Strings.address],
      ticketQuantity: json[Strings.quantity],
      name: json[Strings.name],
      phoneNumber: json[Strings.phoneNbr],
      dateTime: json[Strings.dateTime],
      totalBalance: json[Strings.totalBal],
      remainingBalance: json[Strings.remainingBal],
      revievingBalance: json[Strings.recievingBalance]);

  Map<String, dynamic> toJson() => {
        Strings.documentId: this.docid,
        Strings.name: this.name,
        Strings.email: this.email,
        Strings.phoneNbr: this.phoneNumber,
        Strings.profileImage: this.profileImage,
        Strings.address: this.address,
        Strings.quantity: this.ticketQuantity,
        Strings.dateTime: this.dateTime,
        Strings.totalBal: this.totalBalance,
        Strings.recievingBalance: this.revievingBalance,
        Strings.remainingBal: this.remainingBalance
      };
}
