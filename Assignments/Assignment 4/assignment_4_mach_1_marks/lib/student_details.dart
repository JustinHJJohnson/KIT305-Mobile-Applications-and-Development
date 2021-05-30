import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student.dart';

class StudentDetails extends StatefulWidget {
  var id;

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
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            StudentDetailsForm(student: student, widget: widget),
            Text('Grade average is ${calculateGradeAverage(student)}%'),
            Expanded(
              child: ListView.builder(
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text('Week ${index + 1}'),
                    subtitle: Text('${student.grades[index]}'),
                    //leading: loadImage(student),
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) { return StudentDetails(id: student.studentID); }));
                    },
                  );
                },
                itemCount: student.grades.length,
              ),
            ),
          ]
        )
      ),
    );
  }
}

double calculateGradeAverage(Student student) {
  var gradeAverage = 0;
  for (var grade in student.grades) gradeAverage += grade;
  return gradeAverage / student.grades.length;
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

    firstNameController.text = student.firstName;
    lastNameController.text = student.lastName;
    studentIDController.text = student.studentID;

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
                  TextFormField(
                    decoration: InputDecoration(hintText: "First Name"),
                    controller: firstNameController,
                    validator: (String value) {
                      if (value == null) return "Please enter a first name";
                      else return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: "Last Name"),
                    controller: lastNameController,
                    validator: (String value) {
                      if (value == null) return "Please enter a last name";
                      else return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: "Student ID"),
                    controller: studentIDController,
                    keyboardType: TextInputType.number,   // How to change keyboard type https://stackoverflow.com/questions/49577781/how-to-create-number-input-field-in-flutter
                    validator: (String value) {
                      if (value == null) return "Please enter a student ID";
                      else if (value.contains(RegExp(r'^[0-9]{6}$'))) return "Please enter a 6 digit number";
                      else return null;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton.icon(onPressed: () {
                      if (_formKey.currentState.validate())
                      {
                        /*student.firstName = firstNameController.text;
                        student.lastName = lastNameController.text; //good code would validate these
                        student.studentID = studentIDController.text; //good code would validate these
                        Provider.of<StudentModel>(context, listen: false).update(widget.id, student);*/
                        
                        Navigator.pop(context);
                      }
                    }, icon: Icon(Icons.save), label: Text("Update Student Details"),),
                  )
                ],
              ),
            ),
          ),
        ),
        loadImage(student)
      ],
    );
  }
}

// Used this answer to modify the provided firebase code https://stackoverflow.com/questions/53299919/how-to-display-image-from-firebase-storage-into-widget
Widget loadImage(Student student) {
  print("student image: ${student.image}");
  
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
          if (snapshot.hasData == false) return CircularProgressIndicator();

          var downloadURL = snapshot.data;
          print(downloadURL);
          return Image.network(
            downloadURL,
            //fit: BoxFit.fill,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircularProgressIndicator();
            },
          );
        } 
      )
    );
  }
}