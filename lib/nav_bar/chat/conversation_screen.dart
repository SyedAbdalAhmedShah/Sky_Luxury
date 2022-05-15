import 'dart:ffi';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sky_luxury/blocs/conversation_bloc/conversation_bloc.dart';
import 'package:sky_luxury/blocs/conversation_bloc/conversation_event.dart';
import 'package:sky_luxury/blocs/conversation_bloc/conversation_state.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/agent_model.dart';
import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/model/message.dart';
import 'package:sky_luxury/nav_bar/chat/chat_screen.dart';
import 'package:sky_luxury/repository/conversation_repo.dart';
import 'package:timeago/timeago.dart';

class ConversationScreen extends StatefulWidget {
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  ConversationBloc conversationBloc =
      ConversationBloc(InitialConversationState());
  ConversationRepo repo = ConversationRepo();
  FocusNode _focusNode = FocusNode();

  Stream<List<Conversation>>? stream;
  List<Conversation>? conversation;
  List<Message> messages = [];

  @override
  void initState() {
    print('init---------');
    conversationBloc.add(ConversationById());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: _buildAppBar(size),
        body: BlocListener(
          bloc: conversationBloc,
          listener: (context, state) {
            if (state is SuccessConversationState) {
              stream = state.conversation;
            }
            if (state is DeletedConversationState) {
              setState(() {});
            }
            // TODO: implement listener
          },
          child: BlocBuilder(
            bloc: conversationBloc,
            builder: (context, state) {
              return ModalProgressHUD(
                  inAsyncCall: state is LoadingConversationState,
                  child: _buildStreamBuilder(size));
            },
          ),
        ));
  }

  StreamBuilder<List<Conversation>> _buildStreamBuilder(Size size) {
    return StreamBuilder<List<Conversation>>(
        stream: stream,
        builder: (context, AsyncSnapshot<List<Conversation>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          // print('lenght ${conversation?.length}');
          if (snapshot.hasError) {
            Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.hasData) {
            conversation = snapshot.data!;
            return _buildBody(size);
          }
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        });
  }

  Column _buildBody(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(size.height * 0.02),
          child: _buildMessageText(),
        ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: ((context, index) => _buildListTile(size, index)),
            itemCount: conversation?.length ?? 0,
          ),
        )
      ],
    );
  }

  ListTile _buildListTile(Size size, int index) {
    Conversation convo = conversation![index];
    return ListTile(
      minLeadingWidth: 0,
      horizontalTitleGap: 0,
      minVerticalPadding: 0,
      enabled: true,
      enableFeedback: true,
      contentPadding: EdgeInsets.all(5),
      leading: Badge(
        showBadge: convo.countForAdmin != null && convo.countForAgent != null
            ? AdminManager.isAdminLogedIn && convo.countForAdmin! > 0 ||
                AgentManager.isAgnetLogedIn && convo.countForAgent! > 0
            : false,
        position: BadgePosition.topStart(top: -10, start: 0),
        badgeContent: Text(
          AdminManager.isAdminLogedIn
              ? convo.countForAdmin.toString()
              : AgentManager.isAgnetLogedIn
                  ? convo.countForAgent.toString()
                  : '',
          style: TextStyle(color: Colors.white),
        ),
        child: CircleAvatar(
          radius: size.width * 0.1,
          foregroundImage: AssetImage('assets/no_picture.png'),
        ),
      ),
      title: _userName(conversation![index].username.toString()),
      subtitle: FutureBuilder(
          future: Future.delayed(Duration(milliseconds: 100)).then((value) {
            setState(() {});
          }),
          builder: (_, snap) =>
              _greyText(conversation![index].lastMessage ?? 'Loading....')),
      trailing: _greyText(
          format(conversation![index].timestamp?.toDate() ?? DateTime.now())),
      onTap: () => Get.to(() => ChatScreen(
            conversation: conversation![index],
            isComingFromSearch: false,
          )),
      onLongPress: () => Visibility(
          child: Alerts.cupertinoActionSheet(context,
              message: Strings.deleteConversation, onTap: () {
        Get.back();
        conversationBloc.add(DeleteConversationEvent(
            conversationId: convo.conversationId.toString()));
      })),
    );
  }

  Text _userName(String username) {
    return Text(
      AgentManager.isAgnetLogedIn ? 'Admin' : username,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Text _greyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Strings.kSecondaryColor),
    );
  }

  Text _buildMessageText() {
    return const Text(
      Strings.messages,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    );
  }

  AppBar _buildAppBar(Size size) {
    return AppBar(
      leadingWidth: size.width * 0.07,
      leading: InkWell(),
      elevation: 0,
      toolbarHeight: size.height * 0.13,
      titleSpacing: 0,
      flexibleSpace: backgroundColor(),
      title: _buildSearch(size, context),
    );
  }

  Padding _buildSearch(Size size, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: size.width * 0.08),
      child: TypeAheadField<AgentModel>(
          hideOnLoading: true,
          textFieldConfiguration: TextFieldConfiguration(
              focusNode: _focusNode,
              decoration: InputDecoration(
                  enabledBorder: _border(Strings.kPrimaryColor, size),
                  focusedBorder: _border(Strings.kPrimaryColor, size),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: InkWell(
                      onTap: () => _focusNode.unfocus(),
                      child: Icon(Icons.close)),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Search',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.03,
                    vertical: size.height * 0.023,
                  ))),
          suggestionsCallback: (pattern) {
            return repo.searchAgent(pattern);
          },
          itemBuilder: (context, suggestion) {
            AgentModel agent = suggestion;
            return Container(
              height: size.height * 0.1,
              child: ListTile(
                title: Text(agent.username.toString()),
                subtitle: Text(agent.email.toString()),
              ),
            );
          },
          transitionBuilder: (context, suggestion, controller) {
            return Container(
              height: size.height * 0.4,
              child: suggestion,
            );
          },
          
          onSuggestionSelected: (suggestion) {
            Get.to(() => ChatScreen(
                conversation: Conversation(
                    agentId: suggestion.userID,
                    targetUserID: AdminManager.adminUid,
                    username: suggestion.username,
                    countForAdmin: 0,
                    countForAgent: 0,
                    timestamp: Timestamp.now()),
                isComingFromSearch: true));
          }),

      //  TextFormField(
      //   decoration: InputDecoration(
      //       prefixIcon: Icon(Icons.search),
      //       fillColor: Colors.white,
      //       filled: true,
      //       hintText: 'Search',
      //       border: InputBorder.none,
      //       contentPadding: EdgeInsets.symmetric(
      //         horizontal: size.width * 0.03,
      //         vertical: size.height * 0.023,
      //       ),
      //       focusedBorder: _border(Strings.kPrimaryColor, size),
      //       enabledBorder: _border(Strings.kSecondaryColor, size)),
      // ),
    );
  }

  Container backgroundColor() {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
            Color.fromARGB(255, 118, 188, 245),
            Color.fromARGB(255, 46, 154, 241),
            Strings.kPrimaryColor,
          ])),
    );
  }

  OutlineInputBorder _border(Color color, Size size) {
    return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1.4),
        borderRadius: BorderRadius.circular(size.width * 0.07));
  }
}
