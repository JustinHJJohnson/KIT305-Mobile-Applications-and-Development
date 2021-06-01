import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../student.dart';

/// This is the stateful widget that the main application instantiates.
class GradeAToF extends StatefulWidget {
  final int index;
  final Student student;
  
  const GradeAToF({
    Key key,
    this.index,
    this.student
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
    // This code to solving my sizing problems on the checkbox and label came from here https://stackoverflow.com/questions/51930754/flutter-wrapping-text
    //double containerWidth = MediaQuery.of(context).size.width*0.6;
    //print("Grades for week ${widget.index + 1} is ${widget.student.grades}");

    return ListTile(
      title: Text('Week ${widget.index + 1}'),
      subtitle: Text('${widget.student.grades[widget.index]}'),
      trailing: DropdownButton<String>(
        value: currentValue,
        //icon: const Icon(Icons.arrow_downward),
        //iconSize: 24,
        elevation: 16,
        //style: const TextStyle(color: Colors.deepPurple),
        underline: Container(
          height: 2,
          //color: Colors.deepPurpleAccent,
        ),
        onChanged: (String newValue) {
          setState(() {
            currentValue = newValue;
            // TODO make this update the database
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