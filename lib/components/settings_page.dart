import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).textTheme.headline1?.color),
        toolbarHeight: 80.0,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Text(
                "settings",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(children: [
          SettingsGroup(
            title: 'Appearance',
            children: <Widget>[
              SwitchSettingsTile(
                onChange: (_) {
                  // log("test");
                },
                settingKey: 'key-dark-mode',
                title: 'Dark Mode',
                enabledLabel: 'Enabled',
                disabledLabel: 'Disabled',
                leading: Icon(Icons.palette),
              ),
            ],
          )
        ]),
      ),
    );
  }
}
