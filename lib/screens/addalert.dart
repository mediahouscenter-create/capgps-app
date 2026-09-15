import 'package:flutter/material.dart';
import 'package:maktrogps/screens/alerts/AddAlerts.dart';

class addalert extends StatelessWidget {
  final String? defaultType;
  final bool isTypeLocked;

  const addalert({Key? key, this.defaultType, this.isTypeLocked = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AddAlertsPage(defaultType: defaultType, isTypeLocked: isTypeLocked);
  }
}
