import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../models/week_configs.dart';

Future<void> showWeekConfigDialog(BuildContext context, int weekNum) async {
  return await showDialog(
    context: context,
    builder: (context) {
      final _formKey = GlobalKey<FormState>();
      Map<String, dynamic> weekConfigs = Provider.of<WeekConfigModel>(context, listen: false).weekConfigs;
      String oldGradeType;
      String currentGradeType = weekConfigs["week$weekNum"];
      bool numInputVisible = currentGradeType == "checkBox" || currentGradeType == "score";
      final numInputController = TextEditingController();
      int currentMaxScore;
      int currentNumCheckpoints;

      if (currentGradeType == "score") {
        currentMaxScore = weekConfigs["week${weekNum}MaxScore"];
        numInputController.text = currentMaxScore.toString();
      }
      else if (currentGradeType == "checkBox") {
        currentNumCheckpoints = weekConfigs["week${weekNum}CheckBoxNum"];
        numInputController.text = currentNumCheckpoints.toString();
      }

      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text("Change Grade Type"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),   // Rounded corners from https://stackoverflow.com/questions/58533442/flutter-how-to-make-my-dialog-box-scrollable
          scrollable: true,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Text("Current week config is ${weekConfigs["week$weekNum"]}"),
                  DropdownButton<String> (
                    value: currentGradeType,
                    isDense: true,
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        oldGradeType = currentGradeType;
                        currentGradeType = newValue;
                        numInputVisible = (currentGradeType == "score" || currentGradeType == "checkBox");

                        if (oldGradeType == "score") weekConfigs.removeWhere((key, value) => key == "week${weekNum}MaxScore");
                        else if (oldGradeType == "checkBox") weekConfigs.removeWhere((key, value) => key == "week${weekNum}CheckBoxNum");
                      });
                    },
                    items: <String>["attendance", "gradeA-F", "gradeNN-HD", "score", "checkBox"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  Visibility(
                    visible: numInputVisible,
                    child: TextFormField(
                      decoration: InputDecoration(hintText: currentGradeType == "score" ? "Maximum score" : "Number of checkpoints"),
                      controller: numInputController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      validator: (String value) {
                        if (!value.contains(RegExp(r'^[1-9][0-9]?$|^100$'))) return "Enter a number between 1 and 100";
                        else return null;
                      },
                    ),
                  ),
                  ElevatedButton.icon(onPressed: () {
                    if (_formKey.currentState.validate())
                    {
                      if (currentGradeType == "score") weekConfigs["week${weekNum}MaxScore"] = int.parse(numInputController.text);
                      else if (currentGradeType == "checkBox") weekConfigs["week${weekNum}CheckBoxNum"] = int.parse(numInputController.text);
                      weekConfigs["week$weekNum"] = currentGradeType;

                      Provider.of<WeekConfigModel>(context, listen: false).update(weekConfigs); 
                      Navigator.pop(context);
                    }
                  }, icon: Icon(Icons.save), label: Text("Update Grade Type"))
                ],
              ),
            )
          ),
        );
      });
    }
  );
}