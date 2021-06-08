import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student 
{
  String firstName;
  String lastName;
  String studentID;
  String image;
  List<int> grades;
  
  Student({ this.firstName, this.lastName, this.studentID, this.image, this.grades });
  Student.fromJson(Map<String, dynamic> json)
  :
  firstName = json['firstName'],
        lastName = json['lastName'],
        studentID = json['studentID'],
        image = json['image'],
        grades = json['grades'].cast<int>();

  Map<String, dynamic> toJson() =>
      {
        'firstName': firstName,
        'lastName': lastName,
        'studentID' : studentID,
        'image' : image,
        'grades': grades
      };
}

class StudentModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Student> items = [];

  CollectionReference studentsCollection = FirebaseFirestore.instance.collection("studentsNew");

  bool loading = false;

  //Normally a model would get from a database here, we are just hardcoding some data for this week
  StudentModel() {fetch();}

  void add(Student item) async {
    loading = true;
    notifyListeners();

    await studentsCollection.doc(item.studentID).set(item.toJson());

    // Refresh db
    await fetch();
  }

  void update(String id, Student item) async {
    loading = true;
    notifyListeners();

    if (id != item.studentID) await studentsCollection.doc(id).delete();
    //if (item.grades.length < 12) item.grades = List<int>.filled(12, 0);   // Temporary code to fix students made with old version only having 1 grade

    await studentsCollection.doc(item.studentID).set(item.toJson());

    //refresh the db
    await fetch();
  }

  void delete(String id) async {
    loading = true;
    notifyListeners();

    await studentsCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  Future<void> fetch() async {
    // Clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    // Indicate that we are loading
    loading = true;
    notifyListeners();  // Tell children to redraw, and they will see that the loading indicator is on

    // Get all movies
    var querySnapshot = await studentsCollection.orderBy("studentID").get();

    // Iterate over the movies and add them to the list
    querySnapshot.docs.forEach((doc) {
      // Note not using the add(Student item) function, because we don't want to add them to the db
      var student = Student.fromJson(doc.data());
      items.add(student);
    });

    //we're done, no longer loading
    loading = false;
    notifyListeners();
  }

  Student get(String id) {
    if (id == null) return null;
    return items.firstWhere((student) => student.studentID == id, orElse: () => null);
  }
}