import 'package:assignment_4_mach_1_marks/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';

Future<void> showAddStudentDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) {
      final _formKey = GlobalKey<FormState>();
      final firstNameController = TextEditingController();
      final lastNameController = TextEditingController();
      final studentIDController = TextEditingController();
      final students = Provider.of<StudentModel>(context, listen:false).items;

      String studentImageFilename = "";
    
      Widget studentImage = Icon(Icons.person, size: 120);

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Add Student"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),   // Rounded corners from https://stackoverflow.com/questions/58533442/flutter-how-to-make-my-dialog-box-scrollable
            scrollable: true,
            content: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        var imageURL = await UploadImage().androidIOSUpload(context);
                        setState(() {
                          if (imageURL != null) {
                            studentImage = loadImage(imageURL);
                            studentImageFilename = imageURL.split("/")[1];
                          }
                        });
                      },
                      child: SizedBox(
                        width: 120,
                        //height: 120,
                        child: studentImage,
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
                          student.image = studentImageFilename;
                          Provider.of<StudentModel>(context, listen: false).add(student);
                          
                          Navigator.pop(context);
                        }
                      }, icon: Icon(Icons.save), label: Text("Add Student")),
                    )
                  ],
                ),
              ),
            )
          );
        }
      );
    }
  );
}

Widget loadImage(String imageURL) {
  print("Loading image $imageURL");
  
  return FutureBuilder<String>( //complicated, because getDownloadUrl is async
    future: FirebaseStorage.instance.ref().child(imageURL).getDownloadURL(),
    builder: (context, snapshot) {
      if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());
      
      var downloadURL = snapshot.data;
      print(downloadURL);
      return Image.network(
        downloadURL,
        //fit: BoxFit.fill,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
      );
    } 
  );
}



/*class AddStudentForm extends StatefulWidget {
  const AddStudentForm({
    Key key,
  }) : super(key: key);

  @override
  _AddStudentFormState createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  bool uploading;

  @override
  void initState() {
    super.initState();

    uploading = false;
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final studentIDController = TextEditingController();
    final students = Provider.of<StudentModel>(context, listen:false).items;
    
    Widget studentImage = uploading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors. black),) : Icon(Icons.person, size: 120);

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                setState(() {
                  uploading = true; //visual feedback of upload
                });

                // TODO add code to open camera
                //Navigator.push(context, MaterialPageRoute(builder: (context) { return PictureList(); }));
                var imageURL = await PictureList().androidIOSUpload(context);


                setState(() {
                  uploading = false;

                  FutureBuilder<String>( //complicated, because getDownloadUrl is async
                    future: FirebaseStorage.instance.ref().child(imageURL).getDownloadURL(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) return Center(child: CircularProgressIndicator());

                      var downloadURL = snapshot.data;
                      print(downloadURL);
                      return Image.network(
                        downloadURL,
                        //fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                      );
                    } 
                  );
                });
              },
              child: SizedBox(
                width: 120,
                //height: 120,
                child: studentImage,
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
    );
  }
}*/