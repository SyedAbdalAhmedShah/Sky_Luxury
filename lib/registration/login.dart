import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path/path.dart';
import 'package:sky_luxury/blocs/login_bloc/login_bloc.dart';
import 'package:sky_luxury/blocs/login_bloc/login_event.dart';
import 'package:sky_luxury/blocs/login_bloc/login_state.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/custom_textfield.dart';
import 'package:sky_luxury/components/email_verification_screen.dart';
import 'package:sky_luxury/components/footerText.dart';
import 'package:sky_luxury/components/form_validation.dart';
import 'package:sky_luxury/components/headerText.dart';
import 'package:sky_luxury/components/myButton.dart';
import 'package:sky_luxury/components/onboarding_appbar.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/nav_bar/home_screen.dart';
import 'package:sky_luxury/nav_bar/navbar_screen.dart';
import 'package:sky_luxury/registration/signup.dart';

class LoginScreen extends StatelessWidget {
  LoginBloc bloc = LoginBloc(InitialLoginEvent());
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController resetController = TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: Components.onBoardingAppbar(),
        body: BlocListener(
          bloc: bloc,
          listener: (context, state) {
            if (state is SuccessLoginEvent) {
              if (!state.authResult.user!.emailVerified) {
                Get.to(EmailVerificationScreen());
              } else {
                Get.offAll(() => NavBarScreen());
              }
            }
            if (state is FailureLoginEvent) {
              return Alerts.failureAlertBox(context, state.message);
            }
            if (state is ResetPasswordSuccessfully) {
              Alerts.agentAdded(
                  context, Strings.resetPassowrdLinkMsg, Strings.resetPassword);
            }
          },
          child: BlocBuilder(
            bloc: bloc,
            builder: (context, state) {
              return ModalProgressHUD(
                  inAsyncCall: state is LoadingLoginEvent,
                  child: _buildBody(size, context));
            },
          ),
        ));
  }

  Form _buildBody(Size size, BuildContext context) {
    return Form(
      key: _key,
      child: ListView(
        children: [
          SizedBox(
            height: size.height * 0.03,
          ),
          const HeaderText(
              subtitle: '${Strings.signasAgent} ',
              title: '${Strings.welcom},\n'),
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
          _buildForgetPassText(context),
          SizedBox(
            height: size.height * 0.1,
          ),
          MyButton(buttonText: Strings.login, onTap: createLogin),
          SizedBox(
            height: size.height * 0.1,
          ),
          FooterText(
              firstText: Strings.newAgent,
              secondText: Strings.register,
              onTap: () => Get.to(() => SignupScreen())),
        ],
      ),
    );
  }

  createLogin() {
    if (_key.currentState!.validate()) {
      bloc.add(UserLoginEvent(
          email: emailController.text, password: passwordController.text));
    }
  }

  Align _buildForgetPassText(
    BuildContext context,
  ) {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
          onPressed: () => Alerts.showResetPasswordAlert(
                  context, 'Reset Your Password', 'Enter Password',
                  textEditingController: resetController, onTap: () {
                Navigator.of(context).pop();
                bloc.add(ResetPasswordEvent(email: resetController.text));
              }),
          child: const Text(
            Strings.fpassword,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          )),
    );
  }
}
