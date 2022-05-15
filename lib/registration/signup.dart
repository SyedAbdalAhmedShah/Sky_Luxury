import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sky_luxury/blocs/signup_bloc/signup_bloc.dart';
import 'package:sky_luxury/blocs/signup_bloc/signup_event.dart';
import 'package:sky_luxury/blocs/signup_bloc/signup_state.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/custom_textfield.dart';
import 'package:sky_luxury/components/footerText.dart';
import 'package:sky_luxury/components/form_validation.dart';
import 'package:sky_luxury/components/headerText.dart';
import 'package:sky_luxury/components/myButton.dart';
import 'package:sky_luxury/components/onboarding_appbar.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:get/get.dart';
import 'package:sky_luxury/nav_bar/home_screen.dart';
import 'package:sky_luxury/nav_bar/navbar_screen.dart';
import 'package:sky_luxury/registration/login.dart';

class SignupScreen extends StatelessWidget {
  SignupBloc _bloc = SignupBloc(InitialSignupState());
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Components.onBoardingAppbar(),
      body: BlocListener(
        bloc: _bloc,
        listener: (context, state) {
          if (state is SuccessSignupState) {
            Get.offAll(() => NavBarScreen());
          }
          if (state is FailureSignupState) {
            return Alerts.failureAlertBox(context, state.message);
          }
        },
        child: BlocBuilder(
          bloc: _bloc,
          builder: (context, state) {
            return ModalProgressHUD(
                inAsyncCall: state is LoadingSignupState,
                child: _buildBody(size, state));
          },
        ),
      ),
    );
  }

  Form _buildBody(Size size, state) {
    return Form(
      key: _key,
      child: ListView(
        children: [
          SizedBox(
            height: size.height * 0.03,
          ),
          const HeaderText(
              subtitle: '${Strings.registertoStart} ',
              title: '${Strings.createAccount},\n'),
          CustomTextField(
            obscureText: false,
            hint: Strings.fullName,
            controller: nameController,
            validator: validateName,
          ),
          CustomTextField(
            obscureText: false,
            hint: Strings.emailID,
            controller: emailController,
            validator: validateEmail,
          ),
          CustomTextField(
            obscureText: true,
            hint: Strings.password,
            controller: passwordController,
            validator: validatePassword,
          ),
          SizedBox(
            height: size.height * 0.1,
          ),
          MyButton(buttonText: Strings.signup, onTap: createSignUp),
          SizedBox(
            height: size.height * 0.1,
          ),
          FooterText(
            firstText: Strings.alreadyMember,
            secondText: Strings.login,
            onTap: () => Get.to(() => LoginScreen()),
          )
        ],
      ),
    );
  }

  createSignUp() {
    if (_key.currentState!.validate()) {
      _bloc.add(UserSignupEvent(
          password: passwordController.text,
          userName: nameController.text,
          email: emailController.text));
    }
  }
}
