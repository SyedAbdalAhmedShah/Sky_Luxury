import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sky_luxury/blocs/chat_bloc/chat_events.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/model/conversation.dart';

import '../../blocs/chat_bloc/chat_bloc.dart';
import '../../blocs/chat_bloc/chat_states.dart';
import '../../manager/admin_manager.dart';
import '../../manager/agent_manager.dart';
import '../../model/message.dart';

class PicturePreview extends StatelessWidget {
  final String path;
  final String pathName;
  final Conversation conversation;
  final String? extension;
  PicturePreview(
      {required this.path,
      this.extension,
      required this.pathName,
      required this.conversation});
  ChatBloc chatBloc = ChatBloc(InitialChatState());
  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: chatBloc,
      listener: (context, state) {
        if (state is AttachmentUploadedState) {
          Message message = Message(
              timestamp: Timestamp.now(),
              description: state.firebaseimage,
              userId: AdminManager.isAdminLogedIn
                  ? AdminManager.adminUid
                  : AgentManager.agent.userID,
              userName: AdminManager.isAdminLogedIn
                  ? 'Admin'
                  : AgentManager.agent.username,
              type: Strings.attachment,
              targetUserId: AgentManager.isAgnetLogedIn
                  ? conversation.targetUserID
                  : conversation.agentId);

          chatBloc.add(SendMessageEvent(
              message: message,
              conversationId: conversation.conversationId.toString()));
          Get.back();
        }
      },
      child: BlocBuilder(
        bloc: chatBloc,
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  ModalProgressHUD _buildBody(Object? state) {
    return ModalProgressHUD(
      inAsyncCall: state is LoadingChatState,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () => chatBloc.add(
                    AttachmentSendEvent(imagePath: path, imageName: pathName)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'send',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.send,
                      color: Strings.kPrimaryColor,
                    )
                  ],
                ))
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                  image: extension == Strings.pdf
                      ? AssetImage(Strings.pdfPicture) as ImageProvider
                      : FileImage(File(path)),
                  fit:
                      extension == Strings.pdf ? BoxFit.contain : BoxFit.fill)),
        ),
      ),
    );
  }
}
