import 'package:assignment_4_mach_1_marks/student.dart';
import 'package:assignment_4_mach_1_marks/student_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'add_student_dialog.dart';
import 'week_details.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
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
            return ChangeNotifierProvider(
                create: (context) => StudentModel(), 
                child: MaterialApp(
                  title: 'Mach 1 Marks',
                  theme: ThemeData(
                    primarySwatch: Colors.green,
                  ),
                  home: MyHomePage(title: 'Mach 1 Marks')
                )
            );
            //END: the old MyApp builder from last week
          }

        // Otherwise, show something whilst waiting for initialization to complete
        return FullScreenText(text:"Loading");
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
    return Consumer<StudentModel>(
      builder: tabController
    );
  }

  Widget tabController(BuildContext context, StudentModel studentModel, _) {
    return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(   // Tab code from here https://flutter.dev/docs/cookbook/design/tabs
          tabs: [
            Tab(icon: Icon(Icons.calendar_today)),
            Tab(icon: Icon(Icons.people_alt))
          ],
        ),
      ),
      body: TabBarView(
          children: [
            weekList(),
            studentList(studentModel)
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) { return WeekDetails(weekIndex: week - 1); }));
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

  Widget studentList(StudentModel studentModel) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (studentModel.loading) CircularProgressIndicator() else Expanded(
              child: ListView.builder(
                itemBuilder: (_, index) {
                  var student = studentModel.items[index];
                  return Dismissible(
                    key: Key(student.studentID),
                    onDismissed: (DismissDirection direction) {
                      studentModel.delete(student.studentID);
                      ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('${student.firstName} ${student.lastName} deleted')));
                    },
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    child: ListTile(
                      title: Text('${student.firstName} ${student.lastName}'),
                      subtitle: Text(student.studentID),
                      //leading: loadImage(student),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) { return StudentDetails(id: student.studentID); }));
                      },
                    ),
                  );
                },
                itemCount: studentModel.items.length,
              ),
            ),
          ] 
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => _buildAddStudentDialog(context),
            );
        },
        child: Icon(Icons.person_add),
      )
    );
  }

  // How to create a custom dialog came from here https://fluttercorner.com/how-to-create-popup-in-flutter-with-example/
  Widget _buildAddStudentDialog(BuildContext context) {
    return new AlertDialog(
      title: const Text('Add Student'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),   // Rounded corners from https://stackoverflow.com/questions/58533442/flutter-how-to-make-my-dialog-box-scrollable
      scrollable: true,
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AddStudentForm(),
        ],
      ),
    );
  }

  Widget loadImage(Student student) {
    if (student.image == null)
    {
      return Icon(Icons.person);
    }
    FutureBuilder<String>( //complicated, because getDownloadUrl is async
      future: FirebaseStorage.instance.ref('images/${student.image}').getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.hasData == false)
        {
          return CircularProgressIndicator();
        }

        var downloadURL = snapshot.data;
        print(downloadURL);
        return Image.network(
          downloadURL,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator();
          }
        );
      } 
    );
  }
}

//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}
