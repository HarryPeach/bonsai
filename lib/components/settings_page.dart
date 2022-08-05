import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<String> getGitInfo() async {
  final _head = await rootBundle.loadString('.git/HEAD');
  final commitId = await rootBundle.loadString('.git/ORIG_HEAD');

  final branch = _head.split('/').last;

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  return "app version:${packageInfo.version}+${packageInfo.buildNumber}\ngit branch: $branch\ngit commit: ${commitId.substring(0, 12)}";
}

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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<String>(
                  future: getGitInfo(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? "",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.overline,
                      softWrap: false,
                    );
                  },
                ),
              )
            ],
          )
        ]),
      ),
    );
  }
}
