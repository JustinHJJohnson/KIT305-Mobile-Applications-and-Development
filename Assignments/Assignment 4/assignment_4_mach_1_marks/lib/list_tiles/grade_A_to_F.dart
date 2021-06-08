import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';

/// This is the stateful widget that the main application instantiates.
class GradeAToF extends StatefulWidget {
  final int index;
  final Student student;
  final bool weekList;
  final void Function(Student student) updateGradeAverage;
  
  const GradeAToF({
    Key key,
    this.index,
    this.student,
    this.weekList = false,
    this.updateGradeAverage
  }) : super(key: key);

  @override
  State<GradeAToF> createState() => _GradeAToFState();
}

/// This is the private State class that goes with GradeAToF.
class _GradeAToFState extends State<GradeAToF> {
  String currentValue = 'F';

  @override
  Widget build(BuildContext context) {
    setState(() { 
      final grade = widget.student.grades[widget.index];

      if (grade == 100) currentValue = 'A';
      else if (grade >= 80) currentValue = 'B';
      else if (grade >= 70) currentValue = 'C';
      else if (grade >= 60) currentValue = 'D';
      else currentValue = 'F';
    });
    
    return ListTile(
      title: widget.weekList ? Text("${widget.student.firstName} ${widget.student.lastName}") : Text('Week ${widget.index + 1}'),
      subtitle: widget.weekList ? Text("${widget.student.studentID}") : null,//Text('${widget.student.grades[widget.index]}'),
      trailing: DropdownButton<String>(
        value: currentValue,
        isDense: true,
        elevation: 16,
        underline: Container(
          height: 2,
          color: Theme.of(context).primaryColor,
        ),
        onChanged: (String newValue) {
          setState(() {
            currentValue = newValue;

            switch (newValue)
            {
              case 'A':
                widget.student.grades[widget.index] = 100;
                break;
              case 'B':
                widget.student.grades[widget.index] = 80;
                break;
              case 'C':
                widget.student.grades[widget.index] = 70;
                break;
              case 'D':
                widget.student.grades[widget.index] = 60;
                break;
              case 'F':
                widget.student.grades[widget.index] = 50;
                break;
            }
            
            widget.updateGradeAverage(widget.student);

            Provider.of<StudentModel>(context, listen:false).update(widget.student.studentID, widget.student);
          });
        },
        items: <String>['A', 'B', 'C', 'D', 'F']
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