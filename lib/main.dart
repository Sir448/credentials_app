import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';

import 'list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    EasyDynamicThemeWidget(child: MyApp()),
  );
}
/*
Modularization Plan
Profile
Settings
Authentication
Build list
*/

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credentials',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: CredentialsList(),
    );
  }
}
