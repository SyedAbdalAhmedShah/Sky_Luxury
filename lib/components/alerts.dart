import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sky_luxury/components/cupertino_textfield.dart';
import 'package:sky_luxury/components/custom_textfield.dart';
import 'package:sky_luxury/components/form_validation.dart';

import 'package:sky_luxury/components/myButton.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/model/add_agent.dart';
import 'package:sky_luxury/repository/invoice_repo.dart';

class Alerts {
  static failureAlertBox(BuildContext context, String error) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('OPPS!'),
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: (() => Navigator.of(context).pop()),
                  child: Text('Ok'),
                )
              ],
            ));
  }

  static cupertinoActionSheet(BuildContext context,
      {Function()? onTap, required String message}) {
    return showCupertinoModalPopup(
        context: context,
        builder: (_) => Visibility(
              visible: AdminManager.isAdminLogedIn,
              child: CupertinoActionSheet(
                cancelButton: TextButton(
                    onPressed: () => Get.back(), child: Text('Cancle')),
                message: Text(
                  message,
                  style: TextStyle(color: Strings.kPrimaryColor),
                ),
                actions: [TextButton(onPressed: onTap, child: Text('Delete'))],
              ),
            ));
  }

  static agentAdded(BuildContext context, String error, String title) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: () {
                    int count = 0;
                    Navigator.of(context).popUntil((route) => count++ == 2);
                  },
                  child: Text('Ok'),
                )
              ],
            ));
  }

  static getSnakBar(String message) {
    return Get.snackbar('Opps', message,
        messageText: Text(
          'Please Enter Your Name',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ));
  }

  static showResetPasswordAlert(BuildContext context, String title, String hint,
      {required TextEditingController textEditingController,
      required Function onTap}) {
    GlobalKey<FormState> _key = new GlobalKey();
    bool _validate = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)), //this right here
            child: SingleChildScrollView(
              child: Container(
                height: Size.fromHeight(320).height,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        child: Container(
                            padding: EdgeInsets.all(5),
                            child: Icon(Icons.close)),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            color: Strings.kPrimaryColor,
                            fontFamily: "WorkSans",
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                      key: _key,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: CustomTextField(
                        hint: hint,
                        controller: textEditingController,
                        validator: validateEmail,
                        obscureText: false,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      child: ElevatedButton(
                        child: Text("Send Link"),
                        onPressed: () {
                          if (_key.currentState!.validate()) {
                            onTap();
                          } else {
                            if (!_validate) {
                              _validate = true;
                            }
                          }
                        },
                        // color: Strings.kPrimaryColor,
                        // width: 130,
                        // trailingImage: '',
                      ),
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class CongratulationAlert extends StatelessWidget {
  final AddAgent finance;
  const CongratulationAlert({required this.finance});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return CupertinoDialogAction(
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          width: size.width,
          padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15 + MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size.width * 0.04)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                    child: Icon(
                      Icons.cancel,
                      color: Colors.black,
                    ),
                    onTap: () => Get.back()),
              ),
            ),
            _verticalGap(size),
            Image(
              image: AssetImage(Strings.congrates),
            ),
            _verticalGap(size),
            Text(
              Strings.congratulations,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.w400),
            ),
            _verticalGap(size),
            Text(
              Strings.blanaceUpdateSuccess,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400),
            ),
            _verticalGap(size),
            MyButton(
                buttonText: Strings.generatePdf,
                onTap: () async {
                  Navigator.of(context).pop();
                  final pdfFile =
                      await InvoiceApiProvider.InvoiceMaker(finance);
                  await InvoiceApiProvider.openPdf(pdfFile);
                }),
            _verticalGap(size),
            _verticalGap(size),
          ])),
    );
  }

  SizedBox _verticalGap(Size size) {
    return SizedBox(
      height: size.height * 0.03,
    );
  }
}
