import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_iot/core/theme/theme.dart';
import 'package:project_iot/moduls/home_screen.dart';
import 'package:project_iot/moduls/register/register_screen.dart';
import 'package:project_iot/services/snackbar_service.dart';
import 'package:project_iot/widgets/custom_text_form_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  @override
  static const routeName = "login_screen";

  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var formKey1 = GlobalKey<FormState>();

  bool sec = true;

  Widget build(BuildContext context) {
    var appLocal = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color(0xff1c2120),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 150,
          ),
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Image.asset("assets/images/weather_icon.png"),
          ),
          SizedBox(
            height: 120,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(90))),
              child: Form(
                key: formKey1,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          appLocal.login,
                          style:
                              ApplicationTheme.lightMode.textTheme.titleLarge,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          appLocal.signintocontinue,
                          style: ApplicationTheme.lightMode.textTheme.bodySmall,
                        ),
                        CustomTextFormField(
                            controller: userNameController,
                            title: appLocal.username,
                            labelText: appLocal.name,
                            valdiator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return "you must enter your email";
                              }
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        CustomTextFormField(
                            controller: passwordController,
                            title: appLocal.password,
                            labelText: appLocal.password,
                            suffix_Icon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    sec = !sec;
                                  });
                                },
                                icon: Icon(sec
                                    ? Icons.visibility_off
                                    : Icons.visibility)),
                            sec: sec,
                            valdiator: (String? value) {
                              if (value == null || value.trim().isEmpty) {
                                return "you must enter your password";
                              }
                            }),
                        SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xff1c2120)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                            color: Color(0xff1c2120))))),
                            onPressed: () async {
                              if (formKey1.currentState!.validate()) {
                                login();
                              } else
                                clearTextField();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  appLocal.login,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 25),
                                ),
                                Icon(Icons.arrow_forward),
                              ],
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, RegisterScreen.routeName);
                              clearTextField();
                            },
                            child: Text(
                              appLocal.signup,
                              style: ApplicationTheme
                                  .lightMode.textTheme.bodyMedium,
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userNameController.text, password: passwordController.text);
      // Navigator.pushNamed(context,HomeScreen.routeName);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        SnackBarService.fieldMessage("No user found for that email.");
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        SnackBarService.fieldMessage("Wrong password provided for that user.");
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print("Unexpected error: $e");
      print("Error stack trace: ${StackTrace.current}");
      SnackBarService.successMessage("Login Successfully");
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  clearTextField() {
    userNameController.clear();
    passwordController.clear();
  }
}
