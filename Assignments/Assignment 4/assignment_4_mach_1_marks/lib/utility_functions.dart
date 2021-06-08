import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'models/student.dart';

/// Displays an elevated, rounded snack bar with the primary theme colour as the background colour.
/// code is referenced from https://www.geeksforgeeks.org/flutter-snackbar/
void showCustomSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, textAlign: TextAlign.center),
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(10),
    backgroundColor: Theme.of(context).primaryColor,
  ));
}

/// Build a dialog with the passed in title and children. Code referenced from https://fluttercorner.com/how-to-create-popup-in-flutter-with-example/
Widget buildCustomDialog(BuildContext context, String title, List<Widget> children) {
  return new AlertDialog(
    title: Text(title),
    // Rounded corners from https://stackoverflow.com/questions/58533442/flutter-how-to-make-my-dialog-box-scrollable
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
    scrollable: true,
    content: Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

/// A custom container with rounded edges, elevation and the background colour as the primary theme colour
class RoundedElevatedContainer extends StatelessWidget {
  const RoundedElevatedContainer({
    Key key,
    this.child
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: Container(
        padding: EdgeInsets.fromLTRB(6, 2, 6, 2),
        // Give container rounded corners https://flutteragency.com/give-rounded-corner-to-container/
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: child,
      ),
    );
  }
}

/// Share the grades of all the students passed in. Package used is https://pub.dev/packages/share_plus
void shareAllStudents(List<Student> students) {
  String shareString = "Firstname,Lastname,studentID\n";

  for (var i = 0; i < students[0].grades.length; i++) {shareString += ",week${i}grade";}
  for (var student in students) {
    shareString += "\n${student.firstName},${student.lastName},${student.studentID}";
    for(int grade in student.grades) {shareString += ",$grade";}
  }
  
  Share.share(shareString);
}

/// Share the grades of all the students passed in in the passed in week. Package used is https://pub.dev/packages/share_plus
void shareWeekGrades(List<Student> students, int weekIndex) {
  String shareString = "Firstname,Lastname,studentID,week${weekIndex + 1}grade";

  for (Student student in students) {
    shareString += "\n${student.firstName},${student.lastName},${student.studentID},${student.grades[weekIndex]}";
  }

  Share.share(shareString);
}

/// Share the grades of passed in student. Package used is https://pub.dev/packages/share_plus
void shareStudentsGrades(Student student) {
  String shareString = "Firstname,Lastname,studentID\n";

  for (var i = 0; i < student.grades.length; i++) {shareString += ",week${i}grade";}

  shareString += "${student.firstName},${student.lastName},${student.studentID}";

  for(int grade in student.grades){shareString += ",$grade";}

  Share.share(shareString);
}

/// A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}
