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
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  var txtNameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("My Flutter App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: txtNameController,
                decoration: InputDecoration(
                    hintText: "Enter Name",
                    labelText: "Name"
                ),
              ),
            ),
            ElevatedButton(
              child:Text("Save"),
              onPressed: () =>
              {
                Navigator.push(context, MaterialPageRoute(
                    builder:(context) => SecondPage(name: txtNameController.text)
                ))
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {

  final String name;

  const SecondPage({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Second Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(name),
      ),
    );
  }
}