import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sky_luxury/admin/home/add_agent_screen.dart';

import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_bloc.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_event.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_state.dart';
import 'package:sky_luxury/choose_login.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/cupertino_textfield.dart';
import 'package:sky_luxury/components/drawer.dart';
import 'package:sky_luxury/components/myButton.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/add_agent.dart';
import 'package:sky_luxury/repository/invoice_repo.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  AgentFinanceBloc _bloc = AgentFinanceBloc(InitialFinanceState());
  Stream<List<AddAgent>>? agentsStream;
  List<AddAgent>? agents;
  TextEditingController recievingBalcController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController totalBalanceController = TextEditingController();
  TextEditingController ticketQuantity = TextEditingController();
  final key = GlobalKey<ScaffoldState>();
  SharedPreferences? preferences;

  @override
  void initState() {
    print('inittt');
    _bloc.add(GetAllFinanceAgentEvent());
    init();
    super.initState();
  }

  init() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocListener(
        bloc: _bloc,
        listener: (context, state) {
          if (state is SuccessGetFinanceState) {
            agentsStream = state.agents;
            print(AdminManager.adminName);
            if (preferences?.containsKey(Strings.adminName) == false) {
              showDiloadBoxForName();
            }
          }
          if (state is UpdatedBalanceState) {
            recievingBalcController.clear();
            ticketQuantity.clear();

            Get.back();
            alertttt(size, context, state.finance);
          }
          if (state is LogoutState) {
            print('lougout state');
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => ChooseLoginScreen()),
                (route) => false);
          }
          if (state is AdminNameUpdatedSuccessfull) {
            setState(() {});
          }
        },
        child: BlocBuilder(
            bloc: _bloc,
            builder: (context, state) {
              // TODO: implement listener

              return ModalProgressHUD(
                  inAsyncCall: state is LoadingFetchingFinanceState,
                  child: _buildBody(size, state));
            }));
  }

  Scaffold _buildBody(Size size, state) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: key,
      drawer: Drawer(
        child: CustomDrawer(
          onTap: () => _bloc.add(LogoutEvent()),
        ),
      ),
      appBar: _buildAppBar(size, context),
      body: Stack(
        children: [
          StreamBuilder<List<AddAgent>>(
              stream: agentsStream,
              builder: (context, AsyncSnapshot<List<AddAgent>> snapshot) {
                agents = snapshot.data;
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Text("Press Add Agent button to Add "),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.05,
                        vertical: size.height * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMessageText(),
                        Expanded(
                            child: ListView.builder(
                                itemCount: agents?.length ?? 0,
                                itemBuilder: (_, index) => Slidable(
                                    closeOnScroll: true,
                                    direction: Axis.horizontal,
                                    endActionPane: ActionPane(
                                      motion: ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                            spacing: 12,
                                            autoClose: true,
                                            onPressed: (context) async {
                                              onEditTap(size, context, index);
                                              // onEditTap(size, context);
                                            },
                                            icon: Icons.edit,
                                            backgroundColor: Colors.transparent,
                                            foregroundColor:
                                                Strings.kPrimaryColor),
                                        SlidableAction(
                                            autoClose: true,
                                            spacing: 0,
                                            onPressed: (context) {
                                              _bloc.add(DeleteAgent(
                                                  docId: agents![index]
                                                      .docid
                                                      .toString()));
                                            },
                                            icon: Icons.delete,
                                            backgroundColor: Colors.transparent,
                                            foregroundColor:
                                                Strings.kPrimaryColor)
                                      ],
                                    ),
                                    child: _buildFeedTile(size, index))))
                      ],
                    ),
                  );
                }
                return Center(child: CircularProgressIndicator.adaptive());
              }),
          state is LoadingFetchingFinanceState
              ? Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  SizedBox verticalGap(Size size) {
    return SizedBox(
      height: size.height * 0.03,
    );
  }

  Text _heading(String headingText) {
    return Text(
      headingText,
      style: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.w400, fontSize: 18),
    );
  }

  Text _editBalanceText() {
    return Text(Strings.edditBalance,
        style: TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.w700));
  }

  Card _buildFeedTile(Size size, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            size.width * 0.03,
          ),
          borderSide: BorderSide(color: Colors.transparent)),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        minVerticalPadding: 0,
        minLeadingWidth: 0,
        horizontalTitleGap: 8,
        enabled: true,
        leading: CircleAvatar(
          radius: size.width * 0.07,
          foregroundImage: agents![index].profileImage == null
              ? AssetImage(Strings.noProfile)
              : NetworkImage(agents![index].profileImage!) as ImageProvider,
        ),
        title: Text(
          agents![index].name.toString(),
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Text(
          'Balance: £${agents![index].remainingBalance}',
          style: TextStyle(fontSize: 16),
        ),
        // trailing: Column(
        //   children: [Text('Total Tickets 25')],
        // ),
      ),
    );
  }

  AppBar _buildAppBar(Size size, BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          key.currentState?.openDrawer();
        },
      ),
      backgroundColor: Colors.transparent,
      toolbarHeight: size.height * 0.23,
      flexibleSpace: Container(
        decoration: gradientColor(),
        child: BlocBuilder(
          bloc: _bloc,
          builder: (context, state) {
            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.02,
              ),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                _buildNotifiAndDrawBtn(size),
                _buildVerticalPadding(size, 0.02),
                _userName(),
                _buildVerticalPadding(size, 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildText(Strings.totalAgent),
                        FutureBuilder(
                            future: Future.delayed(Duration(seconds: 1)),
                            builder: (_, snap) => _buildPriceText(
                                agents?.length.toString() ?? '0'))
                      ],
                    ),
                    _addAgent(size)
                  ],
                ),
                _buildVerticalPadding(size, 0.01),
              ],
            );
          },
        ),
      ),
    );
  }

  BoxDecoration gradientColor() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blue,
          Strings.kPrimaryColor,
        ],
      ),
    );
  }

  Text _buildMessageText() {
    return const Text(
      Strings.agentList,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    );
  }

  InkWell _addAgent(Size size) {
    return InkWell(
      onTap: () => Get.to(() => AddAgentScreen())!.then((value) => setState(
            () {},
          )),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(size.width * 0.1)),
        child: Row(
          children: const [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Text(
              Strings.addAgent,
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }

  Text _userName() {
    return Text(
      AdminManager.adminName,
      style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
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

  Row _buildNotifiAndDrawBtn(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => print('heeeey'),
          child: CircleAvatar(
            radius: size.width * 0.03,
            foregroundImage: AssetImage(Strings.adminPicture),
          ),
        ),
        InkWell(
            onTap: () async {
              // final pdfFile = await InvoiceApiProvider.InvoiceMaker(AddAgent(
              //     name: 'Syed abdal shah',
              //     ticketQuantity: 12,
              //     totalBalance: 300,
              //     remainingBalance: 200,
              //     revievingBalance: 100));
              // await InvoiceApiProvider.openPdf(pdfFile);
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
      style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2),
    );
  }

  alertttt(size, context, AddAgent agent) {
    return showDialog(
        context: context,
        builder: (context) => CongratulationAlert(
              finance: agent,
            ));
  }

  Future onEditTap(Size size, BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (_) => BlocBuilder(
              bloc: _bloc,
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: CupertinoDialogAction(
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      margin: MediaQuery.of(context).viewInsets.bottom > 0
                          ? EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom)
                          : EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(
                          horizontal: 15, vertical: size.height * 0.03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(size.width * 0.05)),
                      width: size.width,
                      // height: size.height * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _editBalanceText(),
                          verticalGap(size),
                          _heading(Strings.totalBal),
                          SizedBox(
                            height: size.height * 0.014,
                          ),
                          CustomCupertinoTextField(
                            isGrey: false,
                            hint: agents?[index].totalBalance.toString() ?? '0',
                            keyboardType: TextInputType.number,
                            readOnly: false,
                            controller: totalBalanceController,
                          ),
                          verticalGap(size),
                          _heading(Strings.recievingBalance),
                          SizedBox(
                            height: size.height * 0.014,
                          ),
                          CustomCupertinoTextField(
                            isGrey: true,
                            controller: recievingBalcController,
                            hint: 'Enter Recieveing Balance',
                            readOnly: false,
                            keyboardType: TextInputType.number,
                          ),
                          verticalGap(size),
                          _heading(Strings.remainingBal),
                          SizedBox(
                            height: size.height * 0.014,
                          ),
                          CustomCupertinoTextField(
                            isGrey: false,
                            hint: agents?[index].remainingBalance.toString() ??
                                '0',
                            readOnly: true,
                          ),
                          verticalGap(size),
                          _heading(Strings.quantity),
                          SizedBox(
                            height: size.height * 0.014,
                          ),
                          CustomCupertinoTextField(
                            isGrey: true,
                            controller: ticketQuantity,
                            hint: 'Enter ticket quantity',
                            readOnly: false,
                            keyboardType: TextInputType.number,
                          ),
                          verticalGap(size),
                          _bloc.state is LoadingFetchingFinanceState
                              ? Center(
                                  child: CircularProgressIndicator.adaptive())
                              : MyButton(
                                  margin: EdgeInsets.all(0),
                                  buttonText: Strings.updateBalance,
                                  onTap: () {
                                    if (recievingBalcController
                                            .text.isNotEmpty &&
                                        totalBalanceController
                                            .text.isNotEmpty &&
                                        totalBalanceController
                                            .text.isNotEmpty &&
                                        ticketQuantity.text.isNotEmpty) {
                                      double recieveBacl = double.parse(
                                          recievingBalcController.text);
                                      double totalBalance = double.parse(
                                          totalBalanceController.text);
                                      _bloc.add(UpdateBlanceEvent(
                                          recievingBalance: recieveBacl,
                                          remainingBalance:
                                              agents?[index].remainingBalance ??
                                                  0.0,
                                          totalBalance: totalBalance,
                                          docId:
                                              agents![index].docid.toString(),
                                          ticketQuantity:
                                              int.parse(ticketQuantity.text)));
                                      // if (agents![index].remainingBalance !=
                                      //     0.0) {
                                      //   if (recieveBacl >
                                      //       agents![index].remainingBalance!) {
                                      //     Get.snackbar('OPPS!',
                                      //         'Entered Balance Is More Than the remaining Balance',
                                      //         snackPosition:
                                      //             SnackPosition.BOTTOM);
                                      //   } else {
                                      //     _bloc.add(UpdateBlanceEvent(
                                      //         recievingBalance: recieveBacl,
                                      //         remainingBalance: agents?[index]
                                      //                 .remainingBalance ??
                                      //             0.0,
                                      //         totalBalance:
                                      //             agents?[index].totalBalance ??
                                      //                 0.0,
                                      //         docId: agents![index]
                                      //             .docid
                                      //             .toString(),
                                      //         ticketQuantity: int.parse(
                                      //             ticketQuantity.text)));
                                      //   }
                                      // } else {
                                      //   _bloc.add(UpdateBlanceEvent(
                                      //       recievingBalance: recieveBacl,
                                      //       remainingBalance: agents?[index]
                                      //               .remainingBalance ??
                                      //           0.0,
                                      //       totalBalance:
                                      //           agents?[index].totalBalance ??
                                      //               0.0,
                                      //       ticketQuantity:
                                      //           int.parse(ticketQuantity.text),
                                      //       docId: agents![index]
                                      //           .docid
                                      //           .toString()));
                                      // }
                                    } else {
                                      Get.snackbar('Field Empty',
                                          'Please Enter Recieving Balace',
                                          snackPosition: SnackPosition.BOTTOM);
                                    }
                                  }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ));
  }

  showDiloadBoxForName() {
    // showDialog(context: context, builder: (_)=>  A);
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Text(
                Strings.pleaseEnterName,
                style: TextStyle(fontSize: 20),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  CustomCupertinoTextField(
                    isGrey: false,
                    readOnly: false,
                    padding: 8,
                    controller: nameController,
                  )
                ],
              ),
              actions: [
                CupertinoButton(
                  onPressed: () => nameController.clear(),
                  child: Text(Strings.clear),
                ),
                CupertinoButton(
                  onPressed: () {
                    if (nameController.isBlank! ||
                        nameController.text.isEmpty) {
                      Alerts.getSnakBar(Strings.pleaseEnterName);
                    } else {
                      Get.back();
                      _bloc.add(
                          AdminNameUpdateEvent(adminName: nameController.text));
                    }
                  },
                  child: Text(Strings.update),
                ),
              ],
            ));
  }
}

class ShowBalance extends StatelessWidget {
  final String balance;
  final Size size;
  ShowBalance({
    required this.balance,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(20),
      height: size.height * 0.08,
      width: size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.02),
          border: Border.all(color: Strings.kSecondaryColor, width: 1.2)),
      child: Text(
        balance,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
