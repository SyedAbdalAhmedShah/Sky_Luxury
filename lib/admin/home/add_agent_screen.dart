import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_bloc.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_event.dart';
import 'package:sky_luxury/blocs/agent_finance_bloc/agent_finance_state.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/custom_textfield.dart';
import 'package:sky_luxury/components/form_validation.dart';
import 'package:sky_luxury/components/myButton.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/model/add_agent.dart';

class AddAgentScreen extends StatefulWidget {
  @override
  State<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController phoneController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  ImagePicker _imagePicker = ImagePicker();

  XFile? pickedImage;

  AgentFinanceBloc _bloc = AgentFinanceBloc(InitialFinanceState());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: BlocListener(
            bloc: _bloc,
            listener: (context, state) {
              print(state);
              if (state is SuccessAddedFinanceAgentState) {
                Navigator.of(context).pop();
              }
              if (state is FailureFinanceState) {
                return Alerts.failureAlertBox(context, state.message);
              }
            },
            child: BlocBuilder(
                bloc: _bloc,
                builder: (context, state) {
                  return ModalProgressHUD(
                      inAsyncCall: state is LoadingFetchingFinanceState,
                      child: _buildBody(size, context));

                  //
                })));
  }

  _buildBody(Size size, BuildContext context) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.symmetric(vertical: 8.0, horizontal: size.width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.06,
          ),
          InkWell(
              onTap: () => Get.back(), child: Icon(Icons.adaptive.arrow_back)),
          verticalGap(size),
          addAgentText(),
          verticalGap(size),
          _buildProfilePicture(size, context),
          verticalGap(size),
          CustomTextField(
            obscureText: false,
            hint: Strings.name,
            controller: nameController,
          ),
          verticalGap(size),
          CustomTextField(
              obscureText: false,
              hint: Strings.emailID,
              validator: validateEmail,
              controller: emailController),
          verticalGap(size),
          CustomTextField(
              obscureText: false,
              hint: Strings.phoneNbr,
              keyboardType: TextInputType.phone,
              controller: phoneController),
          verticalGap(size),
          CustomTextField(
              obscureText: false,
              hint: Strings.address,
              controller: addressController),
          MyButton(
              buttonText: Strings.add,
              onTap: () {
                AddAgent agent = AddAgent(
                    address: addressController.text,
                    phoneNumber: phoneController.text,
                    name: nameController.text,
                    dateTime: Timestamp.now(),
                    totalBalance: 0.0,
                    remainingBalance: 0.0,
                    revievingBalance: 0.0,
                    email: emailController.text);
                _bloc.add(AddFinanceAgentEvent(
                    agent: agent,
                    imagePath: pickedImage?.path ?? '',
                    imageName: pickedImage?.name ?? ''));
              })
        ],
      ),
    );
  }

  SizedBox verticalGap(Size size) {
    return SizedBox(
      height: size.height * 0.02,
    );
  }

  Align _buildProfilePicture(Size size, BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          CircleAvatar(
            radius: size.width * 0.15,
            foregroundImage: pickedImage == null
                ? AssetImage(Strings.noProfile)
                : FileImage(File(pickedImage!.path)) as ImageProvider,
          ),
          Positioned(
            right: 5,
            top: size.height * 0.01,
            child: InkWell(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: size.width * 0.03,
                child: Icon(
                  Icons.edit,
                  size: size.width * 0.04,
                ),
              ),
              onTap: () {
                onPictureSelection(size);
              },
            ),
          ),
        ],
      ),
    );
  }

  onPictureSelection(Size size) {
    showModalBottomSheet(
        context: context,
        builder: (_) => Container(
              height: size.height * 0.1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                      onTap: getImageFromGallery,
                      child: Icon(
                        Icons.photo_size_select_actual_rounded,
                        size: size.width * 0.1,
                        color: Strings.kPrimaryColor,
                      )),
                  InkWell(
                      onTap: getImageFromCamera,
                      child: Icon(
                        Icons.camera,
                        size: size.width * 0.1,
                        color: Strings.kPrimaryColor,
                      ))
                ],
              ),
            ));
  }

  Future getImageFromGallery() async {
    XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    print('gallery ${image?.path}');
    if (image != null) {
      setState(() {
        pickedImage = image;
        Get.back();
      });
    }
  }

  Future getImageFromCamera() async {
    XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    print('camera ${image?.path}');

    if (image != null) {
      setState(() {
        pickedImage = image;
        Get.back();
      });
    }
  }

  Text addAgentText() {
    return Text(Strings.smalladdAgent,
        style: TextStyle(
            color: Colors.black,
            letterSpacing: 0.6,
            fontSize: 24,
            fontWeight: FontWeight.w500));
  }
}
