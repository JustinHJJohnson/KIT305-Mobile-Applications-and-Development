import 'package:assignment_4_mach_1_marks/models/student.dart';
import 'package:assignment_4_mach_1_marks/utility_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'dialogs/change_semester_start_dialog.dart';
import 'students_weeks_lists.dart';
import 'models/week_configs.dart';
import 'week_details.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //runApp(MyApp());
  runApp(
    // MultiProvider code from here https://flutterbyexample.com/lesson/multi-provider-micro-lesson
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentModel>(create: (_) => StudentModel()),
        ChangeNotifierProvider<WeekConfigModel>(create: (_) => WeekConfigModel()),
      ],
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget 
{
    // Create the initialization Future outside of `build`:
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    @override
    Widget build(BuildContext context) 
    {
      return FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) //this functio is called every time the "future" updates
        {
          // Check for errors
          if (snapshot.hasError) {
            return FullScreenText(text:"Something went wrong");
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) 
          {
            //BEGIN: the old MyApp builder from last week
            return MaterialApp(
              title: 'Mach 1 Marks',
              theme: ThemeData(primarySwatch: Colors.green),
              home: MyHomePage(title: 'Mach 1 Marks')
            );
            //END: the old MyApp builder from last week
          }

        // Otherwise, show something whilst waiting for initialization to complete
        return FullScreenText(text: "Loading");
      },
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
    // How to have a widget consume multiple providers from here https://stackoverflow.com/questions/59884126/how-to-use-multiple-consumers-for-a-single-widget-in-flutter-provider
    return Consumer2<StudentModel, WeekConfigModel>(
      builder: mainScreen
    );
  }

  Widget mainScreen(BuildContext context, StudentModel studentModel, WeekConfigModel weekConfigModel, _) {
    List<Student> students = studentModel.items;
    String rawStartDate = weekConfigModel.weekConfigs["startDate"];
    DateTime startDate = DateTime.now();
    if (rawStartDate != null) startDate = DateTime.parse(rawStartDate);

    Duration temp = DateTime.now().difference(startDate);
    int currentWeek = temp.inDays ~/ 7;
    if (currentWeek > 12) currentWeek = 12;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share all students grades in csv format',
            onPressed: () {shareAllStudents(students);},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Change the type of grading scheme for this week',
            onPressed: () {
              showDialog(
                builder: (BuildContext context) {
                  return buildCustomDialog(context, "Change Semester Start", [changeSemesterStart(context, startDate)]);
                },
                context: context
              );
            }
          ),
        ]
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("The current week is week $currentWeek"),
            ElevatedButton(
              onPressed: rawStartDate != null ? () {
                Navigator.push(context, MaterialPageRoute(builder: (context) { return WeekDetails(weekIndex: currentWeek - 1); }));
              } : null,
              child: Text(rawStartDate != null ? "Go to current week" : "Loading...")
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) { return StudentsWeeksLists(title: widget.title,);}));
              },
              child: Text("Go to students and weeks lists")
            )
          ],
        ),
      )
    );
  }
}
