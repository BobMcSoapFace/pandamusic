import 'package:flutter/material.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          children: [
            Text("Unknown page")
          ],
        ),
      ),
    );
  }
  

}