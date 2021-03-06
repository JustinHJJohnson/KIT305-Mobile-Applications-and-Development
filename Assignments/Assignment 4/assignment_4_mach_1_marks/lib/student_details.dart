import 'package:assignment_4_mach_1_marks/utility_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'list_tiles/attendance.dart';
import 'list_tiles/grade_A_to_F.dart';
import 'list_tiles/grade_HD_to_NN.dart';
import 'list_tiles/score.dart';
import 'list_tiles/checkpoints.dart';
import 'models/student.dart';
import 'models/week_configs.dart';

class StudentDetails extends StatefulWidget {
  String id;

  StudentDetails({Key key, this.id}) : super(key: key);
  
  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  @override
  Widget build(BuildContext context) {
    var student = Provider.of<StudentModel>(context, listen:false).get(widget.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("Student Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share all students grades in csv format',
            onPressed: () {shareStudentsGrades(student);},
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            StudentDetailsForm(student: student, widget: widget),
            StudentGradeList(student: student),
          ]
        )
      ),
    );
  }
}

class StudentDetailsForm extends StatelessWidget {
  const StudentDetailsForm({
    Key key,
    @required this.student,
    @required this.widget,
  }) : super(key: key);

  final Student student;
  final StudentDetails widget;

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final studentIDController = TextEditingController();
    final students = Provider.of<StudentModel>(context, listen:false).items;

    firstNameController.text = student.firstName;
    lastNameController.text = student.lastName;
    studentIDController.text = student.studentID;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                        validator: (String value) {
                          if (value.isEmpty) return "Please enter a student ID";
                          else if (!value.contains(RegExp(r'^[0-9]{6}$'))) return "Please enter a 6 digit number";
                          else if (student.studentID != value && students.where((otherStudent) => otherStudent.studentID == value).length != 0) return "That student ID is already taken";  // Check for object with certain property from here https://stackoverflow.com/questions/56884062/how-to-search-a-list-of-object-by-another-list-of-items-in-dart
                          else return null;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: ElevatedButton.icon(onPressed: () {
                          if (_formKey.currentState.validate())
                          {
                            student.firstName = firstNameController.text;
                            student.lastName = lastNameController.text;
                            student.studentID = studentIDController.text;
                            //var oldStudentID = widget.id;
                            Provider.of<StudentModel>(context, listen: false).update(widget.id, student);
                            widget.id = student.studentID;
                            
                            showCustomSnackBar(context, "Successfully updated student details");
                          }
                        }, icon: Icon(Icons.save), label: Text("Update Details"),),
                      )
                    ],
                  ),
                ),
              ),
            ),
            loadImage(student)
          ],
        ),
      ],
    );
  }
}

class StudentGradeList extends StatefulWidget {
  StudentGradeList({
    Key key,
    @required this.student,
  }) : super(key: key);

  final Student student;
  double gradeAverage;

  @override
  _StudentGradeListState createState() => _StudentGradeListState();
}

class _StudentGradeListState extends State<StudentGradeList> {
  // code to pass a callback to child widgets to allow them to update this widgets state came from https://medium.com/flutter-community/flutter-communication-between-widgets-f5590230df1e
  _updateGradeAverage(Student student) {
    setState(() {widget.gradeAverage = calculateGradeAverage(student);});
  }

  @override
  Widget build(BuildContext context) {
    widget.gradeAverage = calculateGradeAverage(widget.student);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Grade average is ${widget.gradeAverage}%'),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, index) {
                return getGradeListTile(widget.student, index, context, _updateGradeAverage);
              },
              itemCount: widget.student.grades.length,
            ),
          ),
        ],
      ),
    );
  }
}

Widget getGradeListTile(Student student, int index, BuildContext context, Function(Student student) updateGradeAverage) {
  Map<String, dynamic> weekConfig = Provider.of<WeekConfigModel>(context, listen: false).weekConfigs;
  
  switch (weekConfig["week${index + 1}"]) {
    case "attendance": return Attendance(index: index, student: student, updateGradeAverage: updateGradeAverage);
    case "gradeA-F": return GradeAToF(index: index, student: student, updateGradeAverage: updateGradeAverage);
    case "gradeNN-HD": return GradeHDToNN(index: index, student: student, updateGradeAverage: updateGradeAverage);
    case "score": return Score(index: index, student: student, updateGradeAverage: updateGradeAverage);
    case "checkBox": return Checkpoints(index: index, student: student, updateGradeAverage: updateGradeAverage);
    default: return Text("Grade type not found"); 
  }
}

double calculateGradeAverage(Student student) {
  var gradeSum = 0;
  for (var grade in student.grades) gradeSum += grade;
  var gradeAverage = gradeSum / student.grades.length;
  return num.parse(gradeAverage.toStringAsFixed(2));    // This line of code to round a double to a given number of decimal places came from https://stackoverflow.com/questions/28419255/how-do-you-round-a-double-in-dart-to-a-given-degree-of-precision-after-the-decim
}

// Used this answer to modify the provided firebase code https://stackoverflow.com/questions/53299919/how-to-display-image-from-firebase-storage-into-widget
Widget loadImage(Student student) {
  if (student.image == "") {
    return SizedBox(
      width: 120,
      //height: 120,
      child: Icon(Icons.person, size: 120)
    );
  }
  else {
    return SizedBox(
      width: 120,
      //height: 120,
      child: FutureBuilder<String>( //complicated, because getDownloadUrl is async
        future: FirebaseStorage.instance.ref().child('images/${student.image}').getDownloadURL(),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());

          var downloadURL = snapshot.data;
          return Image.network(
            downloadURL,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: CircularProgressIndicator());
            },
          );
        } 
      )
    );
  }
}