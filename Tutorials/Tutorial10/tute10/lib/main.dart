import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Tutorial 10"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("Hello it is me, Text"),
            ColourfulBox(label:"Hello it is me, PrimaryColourBox 1"),
            ColourfulBox(label:"Hello it is me, PrimaryColourBox 2"),
            ColourfulBox(label:"Hello it is me, PrimaryColourBox 3"),
            ColourfulBox(label:"Hello it is me, PrimaryColourBox 4"),
            ElevatedButton(
              child:Text("Hello it is me, ElevatedButton"),
              onPressed: () => {print("Not so hard!")}
            )
          ],
        )
      ),
    );
  }
}

class ColourfulBox extends StatelessWidget {
  const ColourfulBox({
    Key key, this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(label),
      )
    );
  }
}