import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_luxury/admin/Nav_bar_screen.dart';
import 'package:sky_luxury/admin/home/admin_home.dart';
import 'package:sky_luxury/choose_login.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';
import 'package:sky_luxury/nav_bar/navbar_screen.dart';
import 'package:sky_luxury/registration/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await checkIsUserLogedIn();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    print('is agent loged in :' + AgentManager.isAgnetLogedIn.toString());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SKY LUXURY',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AgentManager.isAgnetLogedIn
          ? NavBarScreen()
          : AdminManager.isAdminLogedIn
              ? AdminNavBarScreen()
              : ChooseLoginScreen(),
    );
  }
}

Future checkIsUserLogedIn() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  AgentManager.isAgnetLogedIn =
      await preferences.containsKey(Strings.agentIsLogedIn);
  AdminManager.isAdminLogedIn = await preferences.containsKey(Strings.adminKey);
  if (AgentManager.isAgnetLogedIn) {
    print('is agent is Loged in' + AgentManager.isAgnetLogedIn.toString());
    final agentData =
        json.decode(preferences.getString(Strings.agentKey) ?? '');
    AgentManager.agent = AgentModel.fromJson(agentData);
  } else if (AdminManager.isAdminLogedIn) {
    AdminManager.isAdminLogedIn =
        await preferences.containsKey(Strings.adminKey);
    AdminManager.adminUid = await preferences.getString(Strings.adminUid) ?? '';
    AdminManager.adminName =
        await preferences.getString(Strings.adminName) ?? '';
    print('Admin uid' + AdminManager.adminUid);
  }
}
