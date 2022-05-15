import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:sky_luxury/admin/home/admin_home.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/cupertino_textfield.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/nav_bar/chat/conversation_screen.dart';

class AdminNavBarScreen extends StatefulWidget {
  const AdminNavBarScreen({Key? key}) : super(key: key);

  @override
  State<AdminNavBarScreen> createState() => _AdminNavBarScreenState();
}

class _AdminNavBarScreenState extends State<AdminNavBarScreen> {
  int currentIndex = 0;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: PageView(
          children: [
            currentIndex == 0 ? AdminHomeScreen() : ConversationScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (int index) async {
              setState(() => currentIndex = index);
              if (currentIndex == 1) {
                await viewConversationUpdateCount();
              }
            },
            items: [
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.home_filled),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home'),
              BottomNavigationBarItem(
                  activeIcon: Icon(Icons.message_sharp),
                  icon: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream:
                          firestore.collection(Strings.adminColl).snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.data == null) {
                          return Icon(Icons.message_outlined);
                        }
                        if (snapshot.hasData) {
                          print(snapshot.data?.docs);
                          if (snapshot.data?.docs.first.data()['count'] !=
                              null) {
                            int count =
                                snapshot.data?.docs.first.data()['count'] ?? 0;

                            return Badge(
                                showBadge: count > 0,
                                child: Icon(Icons.message_outlined));
                          }
                        }
                        return Icon(Icons.message_outlined);
                      }),
                  label: 'Message')
            ]));
  }

  Future viewConversationUpdateCount() async {
    var collection = await firestore.collection(Strings.adminColl).get();
    var doc = collection.docs.first;

    // print('id---------' + collection.id);

    int count = doc.get(Strings.count);
    count = 0;
    doc.reference
        .update({'count': count}).then((value) => print('document updated'));
  }
}
