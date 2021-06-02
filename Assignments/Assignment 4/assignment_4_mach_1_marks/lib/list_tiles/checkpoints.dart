import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../student.dart';

/// This is the stateful widget that the main application instantiates.
class Checkpoints extends StatefulWidget {
  final int index;
  final Student student;
  
  const Checkpoints({
    Key key,
    this.index,
    this.student
    }) : super(key: key);

  @override
  State<Checkpoints> createState() => CheckpointsState();
}

/// This is the private State class that goes with Checkpoints.
class CheckpointsState extends State<Checkpoints> {
  int numCheckpoints = 0;
  Map<String, dynamic> weekConfigs;
  List<bool> isChecked;
  List<Widget> checkBoxes;

  @override
  Widget build(BuildContext context) {
    setState(() { 
      weekConfigs = Provider.of<StudentModel>(context, listen:false).weekConfigs;
      numCheckpoints = weekConfigs["week${widget.index + 1}CheckBoxNum"];

      final int grade = widget.student.grades[widget.index];
      final double numCheckedBoxes = (grade / 100) * numCheckpoints;
      final int numCheckedBoxesCast = numCheckedBoxes.toInt();
      //print("number of checked boxes before cast is $numCheckedBoxes");
      //print("number of checked boxes after cast is $numCheckedBoxesCast");
      isChecked = List<bool>.filled(numCheckpoints, false);
      checkBoxes = List<Widget>.filled(numCheckpoints, null);

      for (var i = 0; i < numCheckpoints; i++) {
        if (i < numCheckedBoxesCast) isChecked[i] = true;

        checkBoxes[i] = Checkbox(
          checkColor: Colors.white,
          value: isChecked[i],
          onChanged: (bool value) {
            setState(() {
              //print("Value for checkbox ${i + 1} is $value");
              isChecked[i] = value;

              int newScore;
              if (value) {
                newScore = ((i + 1) / numCheckpoints * 100).toInt();
                if (newScore != 100) newScore++;    // Add one to solve some rounding issues causing the wrong number of checkboxes to be checked
              }
              else {
                newScore = ((i / numCheckpoints * 100) + 1).toInt();
                if (i == 0) newScore = 0; 
              }

              //print("New score is $newScore");
              this.widget.student.grades[this.widget.index] = newScore;
              Provider.of<StudentModel>(context, listen:false).update(widget.student.studentID, widget.student);
            });
          },
        );
      }
    });

    //double containerWidth = MediaQuery.of(context).size.width*0.6;
    double containerWidth = 200;   // TODO should probably change this to be dynamic

    return ListTile(
      title: Text('Week ${widget.index + 1}'),
      subtitle: Text('${widget.student.grades[widget.index]}'),
      trailing: Container(
        width: containerWidth,
        alignment: Alignment.centerRight,
        // Code to make a row scrollable came from here https://stackoverflow.com/questions/50762079/flutter-listview-scrollable-rowsingle
        // Code to make a row have a dynamic number of children came from here https://stackoverflow.com/questions/58989023/how-to-add-children-to-the-column-dynamically-in-flutter
        // Code to show scrollbar https://flutter-examples.com/show-scrollbar-indicator-in-scrollview-in-flutter/
        child: Scrollbar(
          isAlwaysShown: true,
          child: SingleChildScrollView(
            child: Row(
              children: checkBoxes
            ),
            scrollDirection: Axis.horizontal,
          ),
        )
      ),
    );
  }
}