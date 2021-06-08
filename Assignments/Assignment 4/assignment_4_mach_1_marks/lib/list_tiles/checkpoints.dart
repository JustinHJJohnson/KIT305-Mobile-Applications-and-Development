import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../models/week_configs.dart';

/// This is the stateful widget that the main application instantiates.
class Checkpoints extends StatefulWidget {
  final int index;
  final Student student;
  final bool weekList;
  final void Function(Student student) updateGradeAverage;
  
  const Checkpoints({
    Key key,
    this.index,
    this.student,
    this.weekList = false,
    this.updateGradeAverage
  }) : super(key: key);

  @override
  State<Checkpoints> createState() => CheckpointsState();
}

/// This is the private State class that goes with Checkpoints.
class CheckpointsState extends State<Checkpoints> {
  int numCheckpoints = 0;
  Map<String, dynamic> weekConfigs;
  List<bool> isChecked;
  List<Column> checkBoxes;
  double numCheckedBoxes;

  @override
  Widget build(BuildContext context) {
    setState(() { 
      weekConfigs = Provider.of<WeekConfigModel>(context, listen: false).weekConfigs;
      final numCheckpoints = weekConfigs["week${widget.index + 1}CheckBoxNum"];
      final int grade = widget.student.grades[widget.index];
      numCheckedBoxes = (grade / 100) * numCheckpoints;
      final int numCheckedBoxesCast = numCheckedBoxes.toInt();
      isChecked = List<bool>.filled(numCheckpoints, false);

      checkBoxes = List<Column>.filled(numCheckpoints, null);

      for (var i = 0; i < numCheckpoints; i++) {
        if (i < numCheckedBoxesCast) isChecked[i] = true;

        checkBoxes[i] = Column(
          children: [
            Text("${i + 1}"),
            SizedBox(   // Code to remove padding on checkbox from here https://stackoverflow.com/questions/53152386/flutter-how-to-remove-default-padding-48-px-as-per-doc-from-widgets-iconbut/59420505#59420505
              height: 30,
              width: 30,
              child: Checkbox(
                value: isChecked[i],
                visualDensity: VisualDensity.compact,
                onChanged: (bool value) {
                  setState(() {
                    //print("Value for checkbox ${i + 1} is $value");
                    isChecked[i] = value;

                    int newGrade;
                    if (value) {
                      newGrade = ((i + 1) / numCheckpoints * 100).toInt();
                      if (newGrade != 100) newGrade++;    // Add one to solve some rounding issues causing the wrong number of checkboxes to be checked
                    }
                    else {
                      newGrade = ((i / numCheckpoints * 100) + 1).toInt();
                      if (i == 0) newGrade = 0; 
                    }

                    //print("New score is $newGrade");
                    widget.student.grades[this.widget.index] = newGrade;
                    widget.updateGradeAverage(widget.student);
                    Provider.of<StudentModel>(context, listen:false).update(widget.student.studentID, widget.student);
                  });
                },
              ),
            ),
          ],
        );
      }
    });

    double containerWidth = MediaQuery.of(context).size.width*0.6;
    final ScrollController _controller1 = ScrollController(initialScrollOffset: numCheckedBoxes < 7 ? 0 : numCheckedBoxes * 25 );

    return ListTile(
      title: widget.weekList ? Text("${widget.student.firstName} ${widget.student.lastName}") : Text('Week ${widget.index + 1}'),
      subtitle: widget.weekList ? Text("${widget.student.studentID}") : null,//Text('${widget.student.grades[widget.index]}'),
      trailing: Container(
        width: containerWidth,
        alignment: Alignment.centerRight,
        // Code to make a row scrollable came from here https://stackoverflow.com/questions/50762079/flutter-listview-scrollable-rowsingle
        // Code to make a row have a dynamic number of children came from here https://stackoverflow.com/questions/58989023/how-to-add-children-to-the-column-dynamically-in-flutter
        // Code to always show scrollbar https://flutter-examples.com/show-scrollbar-indicator-in-scrollview-in-flutter/
        child: Scrollbar(
          controller: _controller1,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: _controller1,
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