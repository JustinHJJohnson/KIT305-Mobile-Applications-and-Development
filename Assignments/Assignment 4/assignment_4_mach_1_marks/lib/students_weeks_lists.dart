import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dialogs/add_student_dialog.dart';
import 'models/student.dart';
import 'student_details.dart';
import 'week_details.dart';

class StudentsWeeksLists extends StatefulWidget {
  StudentsWeeksLists({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StudentsWeeksListsState createState() => _StudentsWeeksListsState();
}

class _StudentsWeeksListsState extends State<StudentsWeeksLists> {
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
            WeekList(),
            StudentList(context: context, studentModel: studentModel)
          ],
        ),
      ),
    );
  }


  // ignore: missing_return
  Widget loadImage(Student student) {
    if (student.image == null) {return Icon(Icons.person);}
    FutureBuilder<String>( //complicated, because getDownloadUrl is async
      future: FirebaseStorage.instance.ref('images/${student.image}').getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {return CircularProgressIndicator();}

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

class StudentList extends StatelessWidget {
  const StudentList({
    Key key,
    @required this.context,
    @required this.studentModel,
  }) : super(key: key);

  final BuildContext context;
  final StudentModel studentModel;

  @override
  Widget build(BuildContext context) {
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
                    // This code to confirm the delete of a student from here https://stackoverflow.com/questions/55777213/flutter-how-to-use-confirmdismiss-in-dismissible
                    confirmDismiss: (DismissDirection direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Confirmation"),
                            content: Text("Are you sure you want to delete ${student.firstName} ${student.lastName}?"),
                            actions: [
                              ElevatedButton(
                                onPressed: () {Navigator.of(context).pop(true);},
                                child: Text("Yes")
                              ),
                              ElevatedButton(
                                onPressed: () {Navigator.of(context).pop(false);},
                                child: Text("No")
                              )
                            ],
                          );
                        }
                      );
                    },
                    onDismissed: (DismissDirection direction) {
                      studentModel.delete(student.studentID);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("${student.firstName} ${student.lastName} removed from student list", textAlign: TextAlign.center),
                        elevation: 10,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(10),
                        backgroundColor: Theme.of(context).primaryColor,
                      ));
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
        onPressed: () {showAddStudentDialog(context);},
        child: Icon(Icons.person_add),
      )
    );
  }
}

class WeekList extends StatelessWidget {
  const WeekList({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var weeks = [1,2,3,4,5,6,7,8,9,10,11,12];
    
    return Scaffold(
      body: Center(
        child: Column(
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
}