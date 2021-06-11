import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'dialogs/add_student_dialog.dart';
import 'models/student.dart';
import 'student_details.dart';
import 'week_details.dart';
import 'utility_functions.dart';

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
  Widget loadStudentImage(Student student) {
    if (student.image == null) {return Icon(Icons.person);}
    FutureBuilder<String>( //complicated, because getDownloadUrl is async
      future: FirebaseStorage.instance.ref('images/${student.image}').getDownloadURL(),
      builder: (context, snapshot) {
        if (snapshot.hasData == false) {return CircularProgressIndicator();}

        var downloadURL = snapshot.data;
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

class StudentList extends StatefulWidget {
  StudentList({
    Key key,
    @required this.context,
    @required this.studentModel,
  }) : super(key: key);

  final BuildContext context;
  final StudentModel studentModel;

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  List<Student> students;
  bool sortedAscendingFirstName = false;
  bool sortedAscendingLastName = false;
  bool sortedAscendingStudentID = true;

  @override
  Widget build(BuildContext context) {
    students = widget.studentModel.items;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.studentModel.loading) CircularProgressIndicator() else Expanded(
              child: ListView.builder(
                itemBuilder: (_, index) {
                  var student = students[index];
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
                                child: Text("Yes"),
                                style: ElevatedButton.styleFrom(primary: Colors.red),
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
                      widget.studentModel.delete(student.studentID);
                      showCustomSnackBar(context, "${student.firstName} ${student.lastName} removed from student list");
                    },
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    child: ListTile(
                      title: Text('${student.firstName} ${student.lastName}'),
                      subtitle: Text(student.studentID),
                      //leading: loadStudentImage(student),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) { return StudentDetails(id: student.studentID); }));
                      },
                    ),
                  );
                },
                itemCount: widget.studentModel.items.length,
              ),
            ),
          ] 
        ),
      ),
      floatingActionButton: showSpeedDial(context),
    );
  }

  // This awesome SpeedDial code came from here https://www.geeksforgeeks.org/fab-speed-dial-in-flutter/
  SpeedDial showSpeedDial(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 28.0),
      backgroundColor: Theme.of(context).primaryColor,
      visible: true,
      curve: Curves.bounceInOut,
      elevation: 11,
      children: [
        SpeedDialChild(
          child: Icon(Icons.person_add, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => showAddStudentDialog(context),
          label: 'Add Student',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(sortedAscendingFirstName ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            sortedAscendingFirstName ? students.sort((a, b) => b.firstName.compareTo(a.firstName)) : students.sort((a, b) => a.firstName.compareTo(b.firstName));
            sortedAscendingFirstName = !sortedAscendingFirstName;
            setState(() {});
          },
          label: 'Sort by First Name',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(sortedAscendingLastName ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            sortedAscendingLastName ? students.sort((a, b) => b.lastName.compareTo(a.lastName)) : students.sort((a, b) => a.lastName.compareTo(b.lastName));
            sortedAscendingLastName = !sortedAscendingLastName;
            setState(() {});
          },
          label: 'Sort by Last Name',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: Icon(sortedAscendingStudentID ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: (){
            sortedAscendingStudentID ? students.sort((a, b) => b.studentID.compareTo(a.studentID)) : students.sort((a, b) => a.studentID.compareTo(b.studentID));
            sortedAscendingStudentID = !sortedAscendingStudentID;
            setState(() {});
          },
          label: 'Sort by Student ID',
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
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