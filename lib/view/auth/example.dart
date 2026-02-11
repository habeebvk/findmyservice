import 'package:flutter/material.dart';

class Examples extends StatefulWidget {
  const Examples({super.key});

  @override
  State<Examples> createState() => _ExamplesState();
}

class _ExamplesState extends State<Examples> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("hjbvdsvcdhbcjdncd,vndfksfnvdklfvgdf"),
          Container(
            height: 100,
            width: 200,
            color: Colors.yellow,
            child: Row(
children: [
  Text("HELLO"),SizedBox(width: 20,),
  Text("WORLD"),
],
            ),
          ),
          Icon(Icons.public_outlined),
        ],
      ),
    );
  }
}