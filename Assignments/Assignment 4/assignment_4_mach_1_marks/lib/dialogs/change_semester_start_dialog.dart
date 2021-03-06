import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/week_configs.dart';
import '../utility_functions.dart';

Widget changeSemesterStart(BuildContext context, DateTime intialValue) {
  final dateController = TextEditingController();
  
  return Form(
    child: Column(
      children: [
        // How to add this date picker from here https://flutterforyou.com/how-to-add-date-picker-in-flutter/
        TextField(
          readOnly: true,
          controller: dateController,
          decoration: InputDecoration(
            hintText: 'Pick your Date'
          ),
          onTap: () async {
            var date =  await showDatePicker(
              context: context, 
              initialDate: intialValue,
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now(),
            );
            // Hacky way to convert DateTime format to the same format as iOS DateTime as the date format package I was going to use (intl)
            // redefinded TextDirection which broke the fullscreen text code
            if (date == null) dateController.text = "";
            else dateController.text = date.toString().split(".")[0] + " +0000";
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              //2021-03-13 00:00:00 +0000
              if (dateController.text == "" || dateController.text == "null +0000") {
                showCustomSnackBar(context, "Please enter a new start date");
              }
              else {
                Map<String, dynamic> weekConfigs = Provider.of<WeekConfigModel>(context, listen: false).weekConfigs;
                weekConfigs["startDate"] = dateController.text;
                Provider.of<WeekConfigModel>(context, listen: false).update(weekConfigs);
                Navigator.pop(context);
              }
            },
            child: Text("Update start date")
          ),
        )
      ],
    )
  );  
}