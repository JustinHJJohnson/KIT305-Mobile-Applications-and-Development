import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../student.dart';

/// This is the stateful widget that the main application instantiates.
class Attendance extends StatefulWidget {
  final int index;
  final Student student;
  
  const Attendance({
    Key key,
    this.index,
    this.student
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
    print("Grades for week ${widget.index + 1} is ${widget.student.grades}");

    return ListTile(
      title: Text('Week ${widget.index + 1}'),
      subtitle: Text('${widget.student.grades[widget.index]}'),
      trailing: Container(
        width: containerWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Attendance", textAlign: TextAlign.right),
            Checkbox(
              checkColor: Colors.white,
              value: isChecked,
              onChanged: (bool value) {
                setState(() {
                  isChecked = value;
                  widget.student.grades[widget.index] = value ? 100 : 0;
                  // This code used to make this SnackBar prettier is from https://www.geeksforgeeks.org/flutter-snackbar/
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Button in week ${widget.index + 1} is now $value", textAlign: TextAlign.center),
                    elevation: 10,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(10),
                    backgroundColor: Theme.of(context).primaryColor,
                  ));
                  Provider.of<StudentModel>(context, listen:false).update(widget.student.studentID, widget.student);
                });
              },
            )
          ],
        ),
      )
    );
  }
}