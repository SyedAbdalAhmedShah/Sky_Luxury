import 'package:sky_luxury/components/strings.dart';

class Admin {
  String? email;
  String? adminId;
  int? count;

  Admin({this.adminId, this.count, this.email});

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
        email: json[Strings.email],
        adminId: json[Strings.userID],
        count: json[Strings.count]);
  }

  Map<String, dynamic> toJson() {
    return {
      Strings.email: this.email,
      Strings.userID: this.adminId,
      Strings.count: this.count
    };
  }
}
