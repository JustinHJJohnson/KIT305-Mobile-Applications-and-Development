import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'list_tiles/attendance.dart';
import 'list_tiles/grade_A_to_F.dart';
import 'list_tiles/grade_HD_to_NN.dart';
import 'list_tiles/score.dart';
import 'list_tiles/checkpoints.dart';
import 'student.dart';

class WeekDetails extends StatefulWidget {
  int weekIndex;
  //double gradeAverage;

  WeekDetails({Key key, this.weekIndex}) : super(key: key);
  
  @override
  _WeekDetailsState createState() => _WeekDetailsState();
}

class _WeekDetailsState extends State<WeekDetails> {
  @override
  Widget build(BuildContext context) {
    
    var students = Provider.of<StudentModel>(context, listen:false).items;
    //widget.gradeAverage = calculateGradeAverage(students, widget.weekIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text("Week ${widget.weekIndex + 1} Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //Text('Grade average is ${widget.gradeAverage}%'),
            Text(calculateGradeAverage(students, widget.weekIndex, context)),
            WeekGradeList(students: students, widget: widget),
          ]
        )
      ),
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
  Map<String, dynamic> weekConfig = Provider.of<StudentModel>(context, listen:false).weekConfigs;
  
  switch (weekConfig["week${index + 1}"]) {
    case "attendance": return Attendance(index: index, student: students, weekList: true);
    case "gradeA-F": return GradeAToF(index: index, student: students, weekList: true);
    case "gradeNN-HD": return GradeHDToNN(index: index, student: students, weekList: true);
    case "score": return Score(index: index, student: students, weekList: true);
    case "checkBox": return Checkpoints(index: index, student: students, weekList: true);
    default: return Text("Grade type not found"); 
  }
}

String calculateGradeAverage(List<Student> students, int weekIndex, BuildContext context) {
  final weekConfigs = Provider.of<StudentModel>(context, listen:false).weekConfigs;
  
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
  
  //return num.parse(gradeAverage.toStringAsFixed(2));    // This line of code to round a double to a given number of decimal places came from https://stackoverflow.com/questions/28419255/how-do-you-round-a-double-in-dart-to-a-given-degree-of-precision-after-the-decim
}