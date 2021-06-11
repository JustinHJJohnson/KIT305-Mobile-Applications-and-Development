import 'package:assignment_4_mach_1_marks/utility_functions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dialogs/change_week_config_dialog.dart';
import 'list_tiles/attendance.dart';
import 'list_tiles/grade_A_to_F.dart';
import 'list_tiles/grade_HD_to_NN.dart';
import 'list_tiles/score.dart';
import 'list_tiles/checkpoints.dart';
import 'models/student.dart';
import 'models/week_configs.dart';

class WeekDetails extends StatefulWidget {
  final int weekIndex;

  const WeekDetails({Key key, this.weekIndex}) : super(key: key);
  
  @override
  _WeekDetailsState createState() => _WeekDetailsState();
}

class _WeekDetailsState extends State<WeekDetails> {
  @override
  Widget build(BuildContext context) {
    var students = Provider.of<StudentModel>(context, listen:false).items;

    return Scaffold(
      appBar: AppBar(
        title: Text("Week ${widget.weekIndex + 1} Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share all students grades in csv format',
            onPressed: () {shareWeekGrades(students, widget.weekIndex);},
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
        child: WeekGradeList(students: students, widget: widget, weekIndex: widget.weekIndex)
      ),
    );
  }
}

class WeekGradeList extends StatefulWidget {
  WeekGradeList({
    Key key,
    @required this.students,
    @required this.widget,
    @required this.weekIndex
  }) : super(key: key);

  final List<Student> students;
  final WeekDetails widget;
  final int weekIndex;
  String gradeAverage;

  @override
  _WeekGradeListState createState() => _WeekGradeListState();
}

class _WeekGradeListState extends State<WeekGradeList> {
  _updateGradeAverage(Student student) {
    setState(() {widget.gradeAverage = calculateGradeAverage(student, widget.weekIndex, context);});
  }

  @override
  Widget build(BuildContext context) {
    widget.gradeAverage = calculateGradeAverage(null, widget.weekIndex, context);

    return Column(
      children: [
        Text(widget.gradeAverage),
        Expanded(
          child: ListView.builder(
            itemBuilder: (_, index) {
              return getGradeListTile(widget.students[index], widget.widget.weekIndex, context, _updateGradeAverage);
            },
            itemCount: widget.students.length,
          ),
        ),
      ],
    );
  }
}

Widget getGradeListTile(Student students, int index, BuildContext context, Function(Student student) updateGradeAverage) {
  Map<String, dynamic> weekConfig = Provider.of<WeekConfigModel>(context, listen: true).weekConfigs;
  
  switch (weekConfig["week${index + 1}"]) {
    case "attendance": return Attendance(index: index, student: students, weekList: true, updateGradeAverage: updateGradeAverage);
    case "gradeA-F": return GradeAToF(index: index, student: students, weekList: true, updateGradeAverage: updateGradeAverage);
    case "gradeNN-HD": return GradeHDToNN(index: index, student: students, weekList: true, updateGradeAverage: updateGradeAverage);
    case "score": return Score(index: index, student: students, weekList: true, updateGradeAverage: updateGradeAverage);
    case "checkBox": return Checkpoints(index: index, student: students, weekList: true, updateGradeAverage: updateGradeAverage);
    //default: return Text("Grade type not found");
    default: return Center(child: CircularProgressIndicator());
  }
}

String calculateGradeAverage(Student student, int weekIndex, BuildContext context) {
    final weekConfigs = Provider.of<WeekConfigModel>(context, listen: false).weekConfigs;
    var students =  Provider.of<StudentModel>(context, listen:false).items;
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
      //default: return "Could not find appropriate average";
      default: return "Loading...";
    }
  }