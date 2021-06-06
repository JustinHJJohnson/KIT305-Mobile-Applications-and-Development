import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';

/// This is the stateful widget that the main application instantiates.
class GradeHDToNN extends StatefulWidget {
  final int index;
  final Student student;
  final bool weekList;
  
  const GradeHDToNN({
    Key key,
    this.index,
    this.student,
    this.weekList = false
  }) : super(key: key);

  @override
  State<GradeHDToNN> createState() => _GradeHDToNNState();
}

/// This is the private State class that goes with GradeHDToNN.
class _GradeHDToNNState extends State<GradeHDToNN> {
  String currentValue = 'NN';

  @override
  Widget build(BuildContext context) {
    setState(() { 
      final grade = widget.student.grades[widget.index];

      if (grade == 100) currentValue = 'HD+';
      else if (grade >= 80) currentValue = 'HD';
      else if (grade >= 70) currentValue = 'DN';
      else if (grade >= 60) currentValue = 'CR';
      else if (grade >= 50) currentValue = 'PP';
      else currentValue = 'NN';
    });

    return ListTile(
      title: widget.weekList ? Text("${widget.student.firstName} ${widget.student.lastName}") : Text('Week ${widget.index + 1}'),
      subtitle: widget.weekList ? Text("${widget.student.studentID}") : Text('${widget.student.grades[widget.index]}'),
      trailing: DropdownButton<String>(
        value: currentValue,
        elevation: 16,
        isDense: true,
        underline: Container(
          height: 2,
          color: Theme.of(context).primaryColor,
        ),
        onChanged: (String newValue) {
          setState(() {
            currentValue = newValue;

            switch (newValue)
            {
              case 'HD+':
                widget.student.grades[widget.index] = 100;
                break;
              case 'HD':
                widget.student.grades[widget.index] = 80;
                break;
              case 'DN':
                widget.student.grades[widget.index] = 70;
                break;
              case 'CR':
                widget.student.grades[widget.index] = 60;
                break;
              case 'PP':
                widget.student.grades[widget.index] = 50;
                break;
              case 'NN':
                widget.student.grades[widget.index] = 0;
                break;
            }

            Provider.of<StudentModel>(context, listen:false).update(widget.student.studentID, widget.student);
          });
        },
        items: <String>['HD+', 'HD', 'DN', 'CR', 'PP', 'NN']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}