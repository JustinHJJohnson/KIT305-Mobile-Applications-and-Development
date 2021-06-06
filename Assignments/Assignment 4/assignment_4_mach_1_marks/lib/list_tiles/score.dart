import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../models/week_configs.dart';

/// This is the stateful widget that the main application instantiates.
class Score extends StatefulWidget {
  final int index;
  final Student student;
  final bool weekList;
  
  const Score({
    Key key,
    this.index,
    this.student,
    this.weekList = false
  }) : super(key: key);

  @override
  State<Score> createState() => ScoreState();
}

/// This is the private State class that goes with Score.
class ScoreState extends State<Score> {
  int maxScore = 0;
  Map<String, dynamic> weekConfigs;
  final scoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    setState(() { 
      weekConfigs = Provider.of<WeekConfigModel>(context, listen: false).weekConfigs;
      maxScore = weekConfigs["week${widget.index + 1}MaxScore"];

      final grade = widget.student.grades[widget.index];
      final scaledGrade = (grade / 100) * maxScore;
      
      scoreController.text = scaledGrade.toInt().toString();
    });

    //double containerWidth = MediaQuery.of(context).size.width*0.6;
    double containerWidth = 50;   // TODO should probably change this to be dynamic

    return ListTile(
      title: widget.weekList ? Text("${widget.student.firstName} ${widget.student.lastName}") : Text('Week ${widget.index + 1}'),
      subtitle: widget.weekList ? Text("${widget.student.studentID}") : Text('${widget.student.grades[widget.index]}'),
      trailing: Container(
        width: containerWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: TextField(
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                controller: scoreController,
                onEditingComplete: () {
                  if (int.parse(scoreController.text) > maxScore) scoreController.text = "$maxScore";
                  var newGrade = int.parse(scoreController.text);
                  var newUnscaledGrade = (newGrade / maxScore) * 100;
                  widget.student.grades[widget.index] = newUnscaledGrade.toInt();
                  print("New unscaled grade is $newUnscaledGrade");

                  Provider.of<StudentModel>(context, listen:false).update(widget.student.studentID, widget.student);
                  FocusScope.of(context).requestFocus(new FocusNode());   // This code to close the keyboard is from here https://rrtutors.com/tutorials/flutter-dismiss-keyboard
                },
              ),
            ),
            Text("/$maxScore"),
          ],
        ),
      )
    );
  }
}