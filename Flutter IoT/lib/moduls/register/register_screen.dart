import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_iot/core/theme/theme.dart';
import 'package:project_iot/moduls/login/login_screen.dart';
import 'package:project_iot/services/snackbar_service.dart';
import 'package:project_iot/widgets/custom_text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = "register_screen";

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool sec = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  var formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var appLocal = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color(0xff1c2120),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        backgroundColor: Color(0xff1c2120),
        toolbarHeight: 140,
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(50), topLeft: Radius.circular(30))),
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Form(
            key: formKey2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    appLocal.createnewaccount,
                    style: ApplicationTheme.lightMode.textTheme.titleLarge,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, LoginScreen.routeName);
                      },
                      child: Text(appLocal.alreadyhaveaccount)),
                  SizedBox(
                    height: 12,
                  ),
                  CustomTextFormField(
                    controller: nameController,
                    title: appLocal.username,
                    labelText: appLocal.name,
                    valdiator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "you must enter your name";
                      }
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextFormField(
                    controller: emailController,
                    title: appLocal.email,
                    labelText: appLocal.email,
                    valdiator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "you must enter your email";
                      }
                      var emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                      if (!emailValid.hasMatch(value!)) {
                        return "your email not vaild";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextFormField(
                    controller: passwordController,
                    title: appLocal.password,
                    labelText: appLocal.password,
                    suffix_Icon: IconButton(
                      icon: Icon(sec ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          sec = !sec;
                        });
                      },
                    ),
                    sec: sec,
                    valdiator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "you must enter your password";
                      }
                      var passwordValid =
                          RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$");
                      if (!passwordValid.hasMatch(value)) {
                        return 'Enter valid password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  CustomTextFormField(
                    controller: confirmPasswordController,
                    title: appLocal.confirmpassword,
                    labelText: appLocal.confirmpassword,
                    suffix_Icon: IconButton(
                      icon: Icon(sec ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          sec = !sec;
                        });
                      },
                    ),
                    sec: sec,
                    valdiator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return "you must enter your password";
                      }
                      if (value != passwordController.text) {
                        return "password doesnt match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xff1c2120)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Color(0xff1c2120))))),
                      onPressed: () async {
                        if (formKey2.currentState!.validate()) {
                          register();
                        } else
                          clearTextField();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            appLocal.signup,
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  clearTextField() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }

  register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        SnackBarService.fieldMessage("email-already-in-use");
      }
    } catch (e) {
      SnackBarService.successMessage("You have account now");
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      print(e);
    }
  }
}
