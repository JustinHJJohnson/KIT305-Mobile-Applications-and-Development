import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student.dart';

class AddStudentForm extends StatelessWidget {
  const AddStudentForm({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final studentIDController = TextEditingController();
    final students = Provider.of<StudentModel>(context, listen:false).items;

    return Row(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      print("AddStudentImage clicked");
                      // TODO add code to open camera
                    },
                    child: SizedBox(
                      width: 120,
                      //height: 120,
                      child: Icon(Icons.person, size: 120),
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: "First Name"),
                    controller: firstNameController,
                    validator: (String value) {
                      if (value.isEmpty) return "Please enter a first name";
                      else return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: "Last Name"),
                    controller: lastNameController,
                    validator: (String value) {
                      if (value.isEmpty) return "Please enter a last name";
                      else return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: "Student ID"),
                    controller: studentIDController,
                    keyboardType: TextInputType.number,   // How to change keyboard type https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
                    maxLength: 6,
                    validator: (String value) {
                      if (value.isEmpty) return "Please enter a student ID";
                      else if (!value.contains(RegExp(r'^[0-9]{6}$'))) return "Please enter a 6 digit number";
                      else if (students.where((otherStudent) => otherStudent.studentID == value).length != 0) return "That student ID is already taken";  // Check for object with certain property from here https://stackoverflow.com/questions/56884062/how-to-search-a-list-of-object-by-another-list-of-items-in-dart
                      else return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton.icon(onPressed: () {
                      if (_formKey.currentState.validate())
                      {
                        Student student = Student();
                        
                        student.firstName = firstNameController.text;
                        student.lastName = lastNameController.text;
                        student.studentID = studentIDController.text;
                        student.grades = List<int>.filled(12, 0);   // How to make an empty array of certain size from here https://stackoverflow.com/questions/56997940/flutter-how-to-initialize-an-empty-list-for-every-object-in-an-array
                        student.image = "";
                        Provider.of<StudentModel>(context, listen: false).add(student);
                        
                        Navigator.pop(context);
                      }
                    }, icon: Icon(Icons.save), label: Text("Add Student")),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}