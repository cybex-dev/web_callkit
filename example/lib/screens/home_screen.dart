import 'package:flutter/material.dart';
import 'package:web_callkit_example/utils.dart';

import '../widgets/ck_calls_list.dart';
import 'advanced/advanced_screen.dart';
import 'custom/custom_screen.dart';
import 'simple/simple_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text("Simple Call"),
                  subtitle: const Text(
                    "Show a simple call dialog with a name and a number, will automatically disconnect after 10 seconds if not dismissed already.",
                  ),
                  trailing: TextButton(
                    child: const Text("Click me"),
                    onPressed: () {
                      pushPage(context, const SimpleScreen());
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Advanced Call"),
                  subtitle: const Text(
                    "Test advanced call features such as holding, muting, switching call types between audio, video and screenshare.",
                  ),
                  trailing: TextButton(
                    child: const Text("Click me"),
                    onPressed: () {
                      pushPage(context, const AdvancedScreen());
                    },
                  ),
                ),
                ListTile(
                  title: const Text("Custom Call"),
                  subtitle: const Text(
                    "Test all call features with a custom call.",
                  ),
                  trailing: TextButton(
                    child: const Text("Click me"),
                    onPressed: () {
                      pushPage(context, const CustomScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          ConstrainedBox(
            constraints: BoxConstraints.expand(width: width * 0.25),
            child: const CKCallsList(),
          ),
        ],
      ),
    );
  }
}
