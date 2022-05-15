import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:sky_luxury/blocs/chat_bloc/chat_bloc.dart';
import 'package:sky_luxury/blocs/chat_bloc/chat_events.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/attachment_Cell.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/manager/admin_manager.dart';
import 'package:sky_luxury/manager/agent_manager.dart';
import 'package:sky_luxury/model/conversation.dart';
import 'package:sky_luxury/model/message.dart';
import 'package:sky_luxury/nav_bar/chat/picturePreview.dart';
import 'package:sky_luxury/repository/chat_repo.dart';
import 'package:sky_luxury/repository/conversation_repo.dart';

import '../../blocs/chat_bloc/chat_states.dart';

class ChatScreen extends StatefulWidget {
  final bool isComingFromSearch;
  final Conversation conversation;

  ChatScreen({required this.conversation, required this.isComingFromSearch});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ChatBloc chatBloc = ChatBloc(InitialChatState());
  Stream<List<Message>>? stream;
  String filePath = '';
  String fileName = '';
  String extension = '';
  TextEditingController messageCont = TextEditingController();
  bool? isMe;

  @override
  void initState() {
    if (widget.conversation.conversationId != null) {
      chatBloc.add(GetMessageById(
          conversationId: widget.conversation.conversationId.toString()));
    } else {
      chatBloc
          .add(IsConversationAlreadyExisit(conversation: widget.conversation));
    }

    // print('conversation id -----' + widget.conversation.conversationId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(size),
      body: BlocListener(
        bloc: chatBloc,
        listener: (context, state) {
          if (state is SuccessChatState) {
            stream = state.message;
          }
          if (state is MessageDeletedState) {
            setState(() {});
          }
          if (state is NewConversationCreatedState) {
            chatBloc.add(GetMessageById(conversationId: state.conversationId));
          }
          if (state is ConversationAlreadyExistState) {
            widget.conversation.conversationId = state.conversationId;
            chatBloc.add(GetMessageById(conversationId: state.conversationId));
          }
        },
        child: BlocBuilder(
          bloc: chatBloc,
          builder: (context, state) {
            return _buildBody(size);
          },
        ),
      ),
    );
  }

  StreamBuilder _buildBody(Size size) {
    return StreamBuilder<List<Message>>(
        stream: stream,
        builder: (context, AsyncSnapshot<List<Message>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          if (snapshot.data == null && snapshot.hasError) {
            return Center(
              child: Text('No Messages'),
            );
          }

          if (snapshot.hasData) {
            print(snapshot.data);
            List<Message> messages = snapshot.data!;
            return _buildListViewBuilder(size, messages: messages);
          }

          return Center(
            child: _buildListViewBuilder(
              size,
            ),
          );
        });
  }

  Column _buildListViewBuilder(Size size, {List<Message>? messages}) {
    return Column(
      children: [
        Expanded(
          child: messages == null
              ? widget.isComingFromSearch
                  ? Center(
                      child: Text(
                        'No Chat Yet',
                      ),
                    )
                  : Center(child: CircularProgressIndicator.adaptive())
              : ListView.separated(
                  reverse: true,
                  itemCount: messages.length,
                  separatorBuilder: (_, ind) => SizedBox(
                        height: size.height * 0.02,
                      ),
                  itemBuilder: (_, ind) {
                    String uid = AgentManager.isAgnetLogedIn
                        ? AgentManager.agent.userID.toString()
                        : AdminManager.adminUid;

                    isMe = uid == messages[ind].userId ? true : false;

                    return _buildChatCell(
                      size,
                      messages[ind],
                    );
                  }),
        ),
        _buildTextFieldsWithBtns(size)
      ],
    );
  }

  _buildChatCell(Size size, Message message) {
    if (message.type == Strings.attachment) {
      extension = getExtension(message.description!);
    }
    print('description' + message.userId.toString());
    return GestureDetector(
      onLongPress: () => Alerts.cupertinoActionSheet(context,
          message: Strings.doYouWantToDelete, onTap: () {
        Get.back();
        chatBloc
            .add(MessageDeleteEvent(messageId: message.messageId.toString()));
      }),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe! ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isMe!
                  ? CircleAvatar(
                      radius: size.width * 0.02,
                      foregroundImage: AssetImage('assets/no_picture.png'),
                    )
                  : SizedBox(),
            ],
          ),
          _buildDescriptionAndAttachmentCell(message, size),
          isMe!
              ? SizedBox()
              : CircleAvatar(
                  radius: size.width * 0.02,
                  foregroundImage: AssetImage('assets/no_picture.png'),
                )
        ],
      ),
    );
  }

  Column _buildDescriptionAndAttachmentCell(Message message, Size size) {
    return Column(
      crossAxisAlignment:
          isMe! ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        message.type == Strings.attachment
            ? AttachmentCell(
                path: message.description ?? '',
                isMe: isMe ?? false,
                pathExtension: extension,
              )
            : Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(12),
                decoration: _decoration(size),
                width: size.width * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.userName.toString(),
                      style: TextStyle(
                          color: isMe! ? Colors.purple : Colors.purple.shade200,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      ' ${message.description} ',
                      style: TextStyle(
                          color: isMe! ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
        _messageSendTime(size, message)
      ],
    );
  }

  Padding _messageSendTime(Size size, Message message) {
    return Padding(
      padding: EdgeInsets.only(
          right: isMe! ? 0 : size.width * 0.03,
          left: isMe! ? size.width * 0.03 : 0),
      child: Text(message.timestamp!.toDate().hour.toString() +
          ':' +
          message.timestamp!.toDate().minute.toString()),
    );
  }

  BoxDecoration _decoration(Size size) {
    return BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            offset: Offset(0, 0),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
        color: isMe! ? Colors.grey.shade200 : Strings.kPrimaryColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(size.width * 0.04),
            topRight: Radius.circular(size.width * 0.04),
            bottomLeft:
                isMe! ? Radius.circular(0) : Radius.circular(size.width * 0.04),
            bottomRight: isMe!
                ? Radius.circular(size.width * 0.04)
                : Radius.circular(0)));
  }

  Container _buildTextFieldsWithBtns(Size size) {
    return Container(
      margin: EdgeInsets.only(
          left: size.width * 0.02,
          right: size.width * 0.02,
          bottom: size.height * 0.02),
      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      decoration: _buildDecoration(size),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: messageCont,
            decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: _buildAttachmentBtn(size)),
          )),
          _buildSend(size)
        ],
      ),
    );
  }

  IconButton _buildSend(Size size) {
    return IconButton(
        onPressed: () {
          if (messageCont.text.isBlank!) {
            Alerts.getSnakBar(Strings.pleaseEntermessage);
          } else {
            Message message = Message(
                timestamp: Timestamp.now(),
                description: messageCont.text,
                userId: AdminManager.isAdminLogedIn
                    ? AdminManager.adminUid
                    : AgentManager.agent.userID,
                userName: AdminManager.isAdminLogedIn
                    ? AdminManager.adminName
                    : AgentManager.agent.username,
                type: Strings.comment,
                targetUserId: AgentManager.isAgnetLogedIn
                    ? widget.conversation.targetUserID
                    : widget.conversation.agentId);
            messageCont.clear();
            if (widget.conversation.conversationId == null) {
              print(widget.conversation.conversationId);

              chatBloc.add(CreateConversationAndSendMessage(
                  message: message, conversation: widget.conversation));
            } else {
              chatBloc.add(SendMessageEvent(
                  message: message,
                  conversationId:
                      widget.conversation.conversationId.toString()));
            }
          }
        },
        icon: Icon(
          Icons.send,
          color: Strings.kPrimaryColor,
          size: size.height * 0.04,
        ));
  }

  IconButton _buildAttachmentBtn(Size size) {
    return IconButton(
      onPressed: () => showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => bottomSheet(size)),
      icon:
          Transform.rotate(angle: 170, child: Icon(Icons.attach_file_outlined)),
    );
  }

  BoxDecoration _buildDecoration(Size size) {
    return BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            offset: Offset(0, 0),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(size.width * 0.06));
  }

  bottomSheet(Size size) {
    return Container(
      height: 100,
      width: size.width,
      margin: EdgeInsets.all(8),
      child: Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          InkWell(
              onTap: () async {
                PickedFile? image = await ImagePicker.platform
                    .pickImage(source: ImageSource.camera);

                final filename = p.basename(image!.path);
                print('fileee--' + filename);
                if (image != null) {
                  setState(() {
                    filePath = image.path;
                    fileName = filename;
                  });

                  print(filePath);
                  Get.back();
                  Get.to(PicturePreview(
                    path: filePath,
                    pathName: fileName,
                    conversation: widget.conversation,
                  ));
                }
              },
              child: uploadImages(
                  imagePath: Strings.cameraPicture, text: 'Camera')),
          InkWell(
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpeg', 'jpg', 'svg'],
                );

                if (result != null) {
                  setState(() {
                    filePath = result.files.first.path.toString();
                    fileName = result.files.first.name;
                  });
                  Get.back();

                  String extention = result.files.first.extension.toString();
                  print(filePath);
                  Get.to(PicturePreview(
                    path: filePath,
                    pathName: fileName,
                    conversation: widget.conversation,
                    extension: extention,
                  ));
                }
              },
              child: uploadImages(
                  imagePath: Strings.galleryPicture, text: 'Gallery'))
        ]),
      ),
    );
  }

  Column uploadImages({required String imagePath, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(image: AssetImage(imagePath)),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  AppBar _buildAppBar(Size size) {
    return AppBar(
      toolbarHeight: size.height * 0.1,
      flexibleSpace: backgroundColor(),
      title: Row(
        children: [
          CircleAvatar(
            radius: size.width * 0.08,
            foregroundImage: AssetImage(Strings.noPicture),
          ),
          SizedBox(width: size.width * 0.02),
          Text(
            AgentManager.isAgnetLogedIn
                ? 'Admin'
                : widget.conversation.username.toString(),
            style: TextStyle(fontSize: 16, letterSpacing: 1.5),
          )
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_outlined))
      ],
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

  getExtension(String path) {
    final extensionFromUrl = p.extension(path).split('.').last.split('?').first;
    return extensionFromUrl;
  }
}
