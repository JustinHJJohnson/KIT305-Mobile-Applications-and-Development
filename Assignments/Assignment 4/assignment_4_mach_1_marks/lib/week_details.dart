import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'change_week_config_dialog.dart';
import 'list_tiles/attendance.dart';
import 'list_tiles/grade_A_to_F.dart';
import 'list_tiles/grade_HD_to_NN.dart';
import 'list_tiles/score.dart';
import 'list_tiles/checkpoints.dart';
import 'student.dart';

class WeekDetails extends StatefulWidget {
  final int weekIndex;
  String gradeAverage;

  WeekDetails({Key key, this.weekIndex}) : super(key: key);
  
  @override
  _WeekDetailsState createState() => _WeekDetailsState();

  String calculateGradeAverage(Student student, int weekIndex, BuildContext context) {
    final weekConfigs = Provider.of<StudentModel>(context, listen:true).weekConfigs;
    print(weekConfigs);
    var students =  Provider.of<StudentModel>(context, listen:true).items;
    if (student != null) {
      var studentToUpdate = students.firstWhere((studentToUpdate) => studentToUpdate.studentID == student.studentID);
      studentToUpdate.grades = student.grades;
    }
    
    var gradeSum = 0;
    for (var student in students) gradeSum += student.grades[weekIndex];
    var gradeAverage = gradeSum / students.length;

    switch (weekConfigs["week${weekIndex + 1}"]) {
      case "attendance": return "Grade average is not applicable for attendance";
      case "gradeA-F": 
        if (gradeAverage == 100) return "The average grade is A";
        else if (gradeAverage >= 80) return "The average grade is B";
        else if (gradeAverage >= 70) return "The average grade is C";
        else if (gradeAverage >= 60) return "The average grade is D";
        else return "The average grade is F";
        break;
      case "gradeNN-HD": 
        if (gradeAverage == 100) return "The average grade is HD+";
        else if (gradeAverage >= 80) return "The average grade is HD";
        else if (gradeAverage >= 70) return "The average grade is DN";
        else if (gradeAverage >= 60) return "The average grade is CR";
        else if (gradeAverage >= 50) return "The average grade is PP";
        else return "The average grade is NN";
        break;
      case "score":
        final int maxScore = weekConfigs["week${weekIndex + 1}MaxScore"];
        final double averageScore = (gradeAverage / 100) * maxScore;
        return "The average score is ${averageScore.toInt()}";
      case "checkBox": 
        final int numCheckBoxes = weekConfigs["week${weekIndex + 1}CheckBoxNum"];
        final double averageCheckedBoxes = (gradeAverage / 100) * numCheckBoxes;
        return "The average number of checkpoints complete is ${averageCheckedBoxes.toInt()}";
      default: return "Could not find appropriate average"; 
    }
  }
}

class _WeekDetailsState extends State<WeekDetails> {
  @override
  Widget build(BuildContext context) {
    var students = Provider.of<StudentModel>(context, listen:false).items;
    //widget.gradeAverage = calculateGradeAverage(students, widget.weekIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text("Week ${widget.weekIndex + 1} Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share all students grades in csv format',
            onPressed: () {
              // This share code is from https://pub.dev/packages/share_plus
              String shareString = "Firstname,Lastname,studentID,week${widget.weekIndex + 1}grade";

              for (Student student in students) {
                shareString += "\n${student.firstName},${student.lastName},${student.studentID},${student.grades[widget.weekIndex]}";
              }

              Share.share(shareString);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Change the type of grading scheme for this week',
            onPressed: () {showWeekConfigDialog(context, widget.weekIndex + 1);}
          ),
        ]
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //Text('Grade average is ${widget.gradeAverage}%'),
            //Text(widget.calculateGradeAverage(null, widget.weekIndex, context)),
            WeekGradeList(students: students, widget: widget),
          ]
        )
      ),
      /*floatingActionButton: SpeedDial(
        icon: Icons.menu,

      ),*/
    );
  }
}

class WeekGradeList extends StatelessWidget {
  const WeekGradeList({
    Key key,
    @required this.students,
    @required this.widget
  }) : super(key: key);

  final List<Student> students;
  final WeekDetails widget;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemBuilder: (_, index) {
          return getGradeListTile(students[index], widget.weekIndex, context);
        },
        itemCount: students.length,
      ),
    );
  }
}

Widget getGradeListTile(Student students, int index, BuildContext context) {
  Map<String, dynamic> weekConfig = Provider.of<StudentModel>(context, listen:true).weekConfigs;
  
  switch (weekConfig["week${index + 1}"]) {
    case "attendance": return Attendance(index: index, student: students, weekList: true);
    case "gradeA-F": return GradeAToF(index: index, student: students, weekList: true);
    case "gradeNN-HD": return GradeHDToNN(index: index, student: students, weekList: true);
    case "score": return Score(index: index, student: students, weekList: true);
    case "checkBox": return Checkpoints(index: index, student: students, weekList: true);
    default: return Text("Grade type not found"); 
  }
}