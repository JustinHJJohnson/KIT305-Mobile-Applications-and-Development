import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';

/// This is the stateful widget that the main application instantiates.
class Attendance extends StatefulWidget {
  final int index;
  final Student student;
  final bool weekList;
  final void Function(Student student) updateGradeAverage;
  
  const Attendance({
    Key key,
    this.index,
    this.student,
    this.weekList = false,
    this.updateGradeAverage
  }) : super(key: key);

  @override
  State<Attendance> createState() => _AttendanceState();
}

/// This is the private State class that goes with Attendance.
class _AttendanceState extends State<Attendance> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    if (widget.student.grades[widget.index] == 100) setState(() { isChecked = true; });
    // This code to solving my sizing problems on the checkbox and label came from here https://stackoverflow.com/questions/51930754/flutter-wrapping-text
    double containerWidth = MediaQuery.of(context).size.width*0.6;

    return ListTile(
      title: widget.weekList ? Text("${widget.student.firstName} ${widget.student.lastName}") : Text('Week ${widget.index + 1}'),
      subtitle: widget.weekList ? Text("${widget.student.studentID}") : null,
      trailing: Container(
        width: containerWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Attendance", textAlign: TextAlign.right),
            Checkbox(
              value: isChecked,
              onChanged: (bool value) {
                setState(() {
                  isChecked = value;
                  widget.student.grades[widget.index] = value ? 100 : 0;
                  widget.updateGradeAverage(widget.student);

                  Provider.of<StudentModel>(context, listen:false).update(widget.student.studentID, widget.student);
                  //showCustomSnackBar(context, "updated week ${widget.index + 1} from ${value ? "not attended" : "attended"} to ${value ? "attended" : "not attended"}");
                });
              }
            )
          ],
        ),
      )
    );
  }
}