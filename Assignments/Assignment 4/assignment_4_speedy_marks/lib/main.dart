import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speedy Marks',
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      home: MyHomePage(title: 'Speedy Marks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(   // Tab code from here https://flutter.dev/docs/cookbook/design/tabs
            tabs: [
              Tab(icon: Icon(Icons.people_alt)),
              Tab(icon: Icon(Icons.calendar_today))
            ],
          ),
        ),
        body: TabBarView(
            children: [
              studentList(),
              weekList()
            ],
          ),
      ),
    );
  }

  Widget weekList() {
    var weeks = [1,2,4,5,6,7,8,9,10,11,12];
    
    return Scaffold(
      body: Center(
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var week = weeks[index];
                  return ListTile(
                    title: Text("Week $week"),
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) { return MovieDetails(id: index); }));
                    },
                  );
                },
                itemCount: weeks.length,
              )
            ),
          ]
        )
      )
    );
  }

  Widget studentList() {
    return Scaffold(
       body: Center(
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("This it the student list"),
          ]
        )
      )
    );
  }
}
