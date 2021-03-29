import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/localization/localization.dart';
import 'package:flutter_app/ui_screens/5_stream_builder_check_login_state/signgin_models/users.dart';
import 'localization/language_constants.dart';
import 'pluginsRepositories/SetDefaultDialer.dart';
import 'ui_screens/5_stream_builder_check_login_state/signgin_models/auth.dart';
import 'ui_screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void setDefaultDialer() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = PlatformRepository();
  repository.setDefaultDialer("uid111");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  ));
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  setDefaultDialer();
  runApp(Phoenix(child: MemobeezApp()));
}

class MemobeezApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) {
    _MemobeezAppState state =
        context.findAncestorStateOfType<_MemobeezAppState>();
    state.setLocale(newLocale);
  }

  @override
  _MemobeezAppState createState() => _MemobeezAppState();
}

class _MemobeezAppState extends State<MemobeezApp> {
  Locale _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: missing_required_param
    return StreamProvider<Users>.value(
      value: AuthService().user,
      // initialData: Users(uid: auth.currentUser.phoneNumber),
      child: MaterialApp(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('he', 'IL'),
        ],
        locale: _locale,
        localizationsDelegates: [
          AppLocalization.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          accentColorBrightness: Brightness.light,
          accentColor: Colors.white,
        ),
        home: LoginStateCheck(),
      ),
    );
  }
}
