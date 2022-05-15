import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sky_luxury/admin/Nav_bar_screen.dart';
import 'package:sky_luxury/blocs/login_bloc/login_bloc.dart';
import 'package:sky_luxury/blocs/login_bloc/login_event.dart';
import 'package:sky_luxury/blocs/login_bloc/login_state.dart';
import 'package:sky_luxury/components/alerts.dart';
import 'package:sky_luxury/components/custom_textfield.dart';
import 'package:sky_luxury/components/footerText.dart';
import 'package:sky_luxury/components/form_validation.dart';
import 'package:sky_luxury/components/headerText.dart';
import 'package:sky_luxury/components/myButton.dart';
import 'package:sky_luxury/components/onboarding_appbar.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/nav_bar/home_screen.dart';
import 'package:sky_luxury/nav_bar/navbar_screen.dart';
import 'package:sky_luxury/registration/signup.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  TextEditingController passwordController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  LoginBloc _bloc = LoginBloc(InitialLoginEvent());

  GlobalKey<FormState> _key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: Components.onBoardingAppbar(),
        body: BlocListener(
          bloc: _bloc,
          listener: (context, state) {
            if (state is SuccessLoginEvent) {
              Get.offAll(() => AdminNavBarScreen());
            }
            if (state is FailureLoginEvent) {
              return Alerts.failureAlertBox(context, state.message);
            }
          },
          child: BlocBuilder(
            bloc: _bloc,
            builder: (context, state) {
              return ModalProgressHUD(
                  inAsyncCall: state is LoadingLoginEvent,
                  child: _buildBody(size));
            },
          ),
        ));
  }

  Form _buildBody(Size size) {
    return Form(
      key: _key,
      child: ListView(
        children: [
          SizedBox(
            height: size.height * 0.03,
          ),
          const HeaderText(
              subtitle: '${Strings.signasAdmin} ',
              title: '${Strings.welcom},\n'),
          CustomTextField(
            obscureText: false,
            controller: emailController,
            hint: Strings.adminID,
            validator: validateEmail,
          ),
          CustomTextField(
            obscureText: true,
            controller: passwordController,
            hint: Strings.password,
            validator: validatePassword,
          ),
          // _buildForgetPassText(),
          SizedBox(
            height: size.height * 0.1,
          ),
          MyButton(buttonText: Strings.login, onTap: createLogin),
          SizedBox(
            height: size.height * 0.1,
          ),
        ],
      ),
    );
  }

  createLogin() {
    if (_key.currentState!.validate()) {
      _bloc.add(AdminLoginEvent(
          email: emailController.text, password: passwordController.text));
    }
  }
}

Align _buildForgetPassText() {
  return Align(
    alignment: Alignment.topRight,
    child: TextButton(
        onPressed: () => print('forgot password'),
        child: const Text(
          Strings.fpassword,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        )),
  );
}
