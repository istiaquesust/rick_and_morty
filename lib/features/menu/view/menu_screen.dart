import 'package:flutter/material.dart';
import 'package:rick_and_morty/custom_widgets/custom_text.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() {
    return _MenuScreen();
  }
}

class _MenuScreen extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CustomText(
              text:
                  'This menu screen enhances the bottom navigation, ensuring a balanced and cohesive look.',
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  //methods
}
