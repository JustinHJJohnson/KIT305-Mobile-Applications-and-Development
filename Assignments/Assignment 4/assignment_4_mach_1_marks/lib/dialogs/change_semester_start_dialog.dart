import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/week_configs.dart';

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

            dateController.text = date.toString().split(".")[0] + " +0000"; // Hacky way to convert DateTime format to the same format as iOS DateTime     
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              Map<String, dynamic> weekConfigs = Provider.of<WeekConfigModel>(context, listen: false).weekConfigs;
              weekConfigs["startDate"] = dateController.text;
              Provider.of<WeekConfigModel>(context, listen: false).update(weekConfigs);
              Navigator.pop(context);
            },
            child: Text("Update start date")
          ),
        )
      ],
    )
  );  
}