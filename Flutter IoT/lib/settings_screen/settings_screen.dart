import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_provider/app_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../moduls/login/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = "setting_screen";

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? selectedLanguage = "En";

  void initState() {
    super.initState();
    getLanguageStoredInDevice();
  }

  @override
  Widget build(BuildContext context) {
    var appLocal = AppLocalizations.of(context)!;
    var theme = Theme.of(context);
    var appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocal.settings,
          style: theme.textTheme.titleLarge,
        ),
        toolbarHeight: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                appLocal.changelanguage,
                style: theme.textTheme.bodyMedium,
              ),
              leading: Icon(
                Icons.language,
                size: 40,
              ),
              trailing: DropdownButton(
                  items: [
                    DropdownMenuItem(
                      child: Text("En"),
                      value: "en",
                    ),
                    DropdownMenuItem(
                      child: Text("Ar"),
                      value: "ar",
                    )
                  ],
                  value: selectedLanguage ?? "en",
                  onChanged: (value) async {
                    if (value != null) {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      pref.setString("language", value);
                      setState(() {
                        selectedLanguage = value;
                      });
                      if (value == "en") {
                        appProvider.changeLanguage("en");
                      } else {
                        appProvider.changeLanguage("ar");
                      }
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: 40,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, LoginScreen.routeName);
                      },
                      child: Text(
                        appLocal.logout,
                        style: theme.textTheme.bodyMedium,
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  getLanguageStoredInDevice() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = pref.getString("language") ?? "en";
    });
  }
}
