import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

Future<bool> authenticate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int authMethod = prefs.getInt('authMethod');
  if (authMethod == 1) {
  } else if (authMethod == 2) {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (canCheckBiometrics) {
      bool authenticated = false;
      try {
        authenticated = await auth.authenticate(
            biometricOnly: true,
            localizedReason: "Please verify to view credentials");
      } on PlatformException catch (e) {
        print(e);
      }
      return authenticated;
    }
  }
}

Future<void> setAuth(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();
  int pin;
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<BiometricType> availableBiometrics;
  try {
    availableBiometrics = await auth.getAvailableBiometrics();
  } on PlatformException catch (e) {
    print(e);
  }

  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  Widget enterButton = TextButton(
    child: Text("Enter"),
    onPressed: () {
      if (_formKey.currentState.validate()) {
        prefs.setInt('authMethod', 0);
        prefs.setInt('pin', pin);
        Navigator.of(context).pop();
      }
    },
  );

  AlertDialog setPin = AlertDialog(
    title: Text("Set Pin"),
    content: Form(
      key: _formKey,
      child: TextFormField(
        style: TextStyle(fontSize: 20),
        decoration: InputDecoration(
          hintText: 'Pin',
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value.isEmpty) {
            return 'Cannot be empty';
          } else if (int.tryParse(value) == null) {
            return 'Must be numbers only';
          }
          return null;
        },
        onChanged: (value) {
          pin = int.tryParse(value);
        },
      ),
    ),
    actions: [
      cancelButton,
      enterButton,
    ],
  );

  Widget noneButton = TextButton(
    child: Text("None"),
    onPressed: () {
      prefs.setInt('authMethod', 0);
      Navigator.of(context).pop();
    },
  );

  Widget pinButton = TextButton(
    child: Text("Pin"),
    onPressed: () {
      prefs.setInt('authMethod', 1);
      Navigator.of(context).pop();
      // showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (BuildContext context) {
      //       return setPin;
      //     });
    },
  );

  Widget biometricButton = TextButton(
    child: Text(availableBiometrics.contains(BiometricType.fingerprint)
        ? "Fingerprint"
        : "Face"),
    onPressed: () {
      prefs.setInt('authMethod', 2);
      Navigator.of(context).pop();
    },
  );

  AlertDialog chooseAuth = AlertDialog(
    title: Text("Choose Authentication Type"),
    actions: [
      noneButton,
      pinButton,
      availableBiometrics.isNotEmpty ? biometricButton : null,
    ],
  );

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return chooseAuth;
      });
}
