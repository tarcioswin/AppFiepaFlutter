import 'package:flutter/material.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain MediaQueryData
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    
    // Get the size of the screen
    Size screenSize = mediaQueryData.size; // This holds the size of the screen
    
    
    // Displaying the screen width and height
    return Scaffold(
      appBar: AppBar(title: const Text("Screen Dimensions")),
      body: Center(
        child: Text('Screen size: ${screenSize.width} x ${screenSize.height}'),
      ),
    );
  }
}
