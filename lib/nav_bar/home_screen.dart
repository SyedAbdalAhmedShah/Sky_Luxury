import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_luxury/blocs/agent_homeBloc/agent_home_bloc.dart';
import 'package:sky_luxury/blocs/agent_homeBloc/agent_home_event.dart';
import 'package:sky_luxury/blocs/agent_homeBloc/agent_home_state.dart';
import 'package:sky_luxury/choose_login.dart';
import 'package:sky_luxury/components/drawer.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';

import '../components/alerts.dart';
import '../components/cupertino_textfield.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController ticketController = TextEditingController();

  TextEditingController balanceContoller = TextEditingController();

  AgentHomeBloc bloc = AgentHomeBloc(AgentHomeInitialState());
  @override
  void initState() {
    bloc.add(GetAgentDataByDocId(
        documentId: AgentManager.agent.documentId.toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener(
      bloc: bloc,
      listener: (context, state) {
        if (state is UpdatedBalanceSuccessfully) {
          setState(() {});
        }
        if (state is UpdatedTicketsSuccessfully) {
          setState(() {});
        }
        if (state is AgentGetSuccessfully) {
          setState(() {});
        }
      },
      child: BlocBuilder(
        bloc: bloc,
        builder: (context, state) {
          return ModalProgressHUD(
              inAsyncCall: state is AgentHomeLoadingState,
              progressIndicator: CircularProgressIndicator.adaptive(),
              child: _buildScaffold(context, size));
        },
      ),
    );
  }

  Scaffold _buildScaffold(BuildContext context, Size size) {
    return Scaffold(
      drawer: _buildDrawer(context),
      key: scaffoldKey,
      appBar: _buildAppBar(size, context),
      body: _buildBody(size, context),
    );
  }

  Column _buildBody(Size size, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCircularButton(size,
                isRight: true,
                title: Strings.edditBalance,
                onTap: () => showDiloadBoxForName(context,
                        controller: balanceContoller,
                        text: Strings.pleaseEnterBalance, onTap: () {
                      bloc.add(
                        UpdateBalanceEvent(
                            balance: double.parse(balanceContoller.text)),
                      );
                      balanceContoller.clear();
                    })),
            _buildCircularButton(size,
                isRight: false,
                title: Strings.editTickets,
                onTap: () => showDiloadBoxForName(context,
                        controller: ticketController,
                        text: Strings.pleaseEnterTicker, onTap: () {
                      bloc.add(UpdateTicketsEvent(
                          tickets: double.parse(ticketController.text)));
                      ticketController.clear();
                    }))
          ],
        ),
        Image(image: AssetImage(Strings.officalLogo))
      ],
    );
  }

  AppBar _buildAppBar(Size size, BuildContext context) {
    return AppBar(
      leading: InkWell(onTap: (() => scaffoldKey.currentState?.openDrawer())),
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: size.height * 0.2,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Strings.kPrimaryColor,
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.02, vertical: size.height * 0.05),
          children: [
            _buildNotAndDrawBtn(context),
            _buildVerticalPadding(size, 0.03),
            SizedBox(
              height: size.height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _buildText(Strings.totalBal),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    _buildText(AgentManager.agent.balance != null
                        ? AgentManager.agent.balance.toString()
                        : 0.toString()),
                  ],
                ),
                Column(
                  children: [
                    _buildText(Strings.totalTicSale),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    _buildText(AgentManager.agent.balance != null
                        ? '${AgentManager.agent.tickets!.toString()}'
                        : 0.toString()),
                  ],
                )
              ],
            ),
            _buildVerticalPadding(size, 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // _buildPriceText('\$1000.9'),
                // _buildPriceText('\$510')
              ],
            )
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(child: CustomDrawer(onTap: () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await auth.signOut().then((value) => print('lougout'));
      AgentManager.agent = AgentModel();
      AgentManager.isAgnetLogedIn = false;
      await preferences
          .clear()
          .then((value) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => ChooseLoginScreen()),
              (route) => false))
          .then((value) => AgentManager.agent = AgentModel());
    }));
  }

  InkWell _buildCircularButton(Size size,
      {Function()? onTap, String? title, required bool isRight}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
        child: Text(
          title ?? '',
          style: TextStyle(
              fontSize: 14,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Strings.kPrimaryColor.withOpacity(0.7)),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.01, vertical: size.height * 0.03),
        decoration: BoxDecoration(
          border: Border.all(color: Strings.kPrimaryColor, width: 2),
          borderRadius: isRight
              ? BorderRadius.only(
                  topRight: Radius.circular(size.width * 0.2),
                  bottomRight: Radius.circular(size.width * 0.2))
              : BorderRadius.only(
                  topLeft: Radius.circular(size.width * 0.2),
                  bottomLeft: Radius.circular(size.width * 0.2)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 5), // changes position of shadow
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _buildVerticalPadding(Size size, double height) {
    return SizedBox(
      height: size.height * height,
    );
  }

  Text _buildPriceText(String text) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 2,
          fontWeight: FontWeight.w500),
    );
  }

  Row _buildNotAndDrawBtn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
            onTap: () {},
            child: const Icon(
              Icons.menu,
              color: Colors.white,
            )),
        InkWell(
            onTap: () {
              print(AdminManager.adminName);
              print(AdminManager.adminUid);
            },
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
            )),
      ],
    );
  }

  Text _buildText(
    String text,
  ) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          letterSpacing: 2,
          fontWeight: FontWeight.bold),
    );
  }

  showDiloadBoxForName(BuildContext context,
      {required TextEditingController? controller,
      required String text,
      required Function() onTap}) {
    // showDialog(context: context, builder: (_)=>  A);
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text(
                text,
                style: TextStyle(fontSize: 20),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  CustomCupertinoTextField(
                    keyboardType: TextInputType.number,
                    isGrey: false,
                    readOnly: false,
                    padding: 8,
                    controller: controller,
                  )
                ],
              ),
              actions: [
                CupertinoButton(
                  onPressed: () => Get.back(),
                  child: Text(Strings.back),
                ),
                CupertinoButton(
                  onPressed: () {
                    if (controller!.text.isEmpty || controller.text.isEmpty) {
                      Alerts.getSnakBar(text);
                    } else {
                      Get.back();
                      onTap();
                    }
                  },
                  child: Text(Strings.update),
                ),
              ],
            ));
  }

  Future logOut(BuildContext context) async {}
}
