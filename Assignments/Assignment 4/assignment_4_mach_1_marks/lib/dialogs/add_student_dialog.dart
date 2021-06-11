import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../utility_functions.dart';

Future<void> showAddStudentDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) {
      final _formKey = GlobalKey<FormState>();
      final firstNameController = TextEditingController();
      final lastNameController = TextEditingController();
      final studentIDController = TextEditingController();
      final students = Provider.of<StudentModel>(context, listen:false).items;
      final imagePicker = ImagePicker();
    
      Widget studentImage = Icon(Icons.add_a_photo, size: 120);
      File studentImageFile;
      bool uploading = false;

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
                    studentImage.key == Key("string") ? SizedBox(
                       width: 120,
                       //height: 120,
                       child: studentImage,
                    ) :
                    Column(
                      children: [
                        Text("Add student image"),
                        Row(
                          children: [
                            ElevatedButton(onPressed: () async {
                              // Camera functionality from https://pub.dev/packages/image_picker
                              PickedFile image = await imagePicker.getImage(source: ImageSource.camera, maxWidth: 720, maxHeight: 480);
                              if (image != null) {
                                File imageConverted = File(image.path);
                                setState(() {
                                  studentImage = Image.file(imageConverted, key: Key("string"));
                                  studentImageFile = imageConverted;
                                });
                              }
                            },
                              child: Text("Take photo")
                            ),
                            ElevatedButton(onPressed: () async {
                              PickedFile image = await imagePicker.getImage(source: ImageSource.gallery, maxWidth: 720, maxHeight: 480);
                              if (image != null) {
                                File imageConverted = File(image.path);
                                setState(() {
                                  studentImage = Image.file(imageConverted, key: Key("string"));
                                  studentImageFile = imageConverted;
                                });
                              }
                            },
                              child: Text("From gallery")
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: InputDecoration(hintText: "First Name"),
                      controller: firstNameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (String value) {
                        if (value.isEmpty) return "Please enter a first name";
                        else return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(hintText: "Last Name"),
                      controller: lastNameController,
                      textCapitalization: TextCapitalization.words,
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
                      child: !uploading ? ElevatedButton.icon(onPressed: () async {
                        if (_formKey.currentState.validate())
                        {
                          FocusScope.of(context).requestFocus(new FocusNode());   // This code to close the keyboard is from here https://rrtutors.com/tutorials/flutter-dismiss-keyboard
                          Student student = Student();
                          
                          student.firstName = firstNameController.text;
                          student.lastName = lastNameController.text;
                          student.studentID = studentIDController.text;
                          student.grades = List<int>.filled(12, 0);   // How to make an empty array of certain size from here https://stackoverflow.com/questions/56997940/flutter-how-to-initialize-an-empty-list-for-every-object-in-an-array
                          
                          setState(() {uploading = true;});

                          student.image = await uploadStudentImage(studentImageFile, null);
                          Provider.of<StudentModel>(context, listen: false).add(student);
                          
                          Navigator.pop(context);
                        }
                      }, icon: Icon(Icons.save), label: Text("Add Student"))
                      : ElevatedButton(onPressed: null, child: Text("Uploading..."),),
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
