import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeekConfigModel extends ChangeNotifier {
  
  final Map<String, dynamic> weekConfigs = {};

  DocumentReference weekConfigCollection = FirebaseFirestore.instance.collection("gradesConfig").doc("UK71QI0qFPiP2zcmsclx");

  bool loading = false;

  // Normally a model would get from a database here, we are just hardcoding some data for this week
  WeekConfigModel() {fetch();}

  void update(Map<String, dynamic> item) async {
    //loading = true;
    //notifyListeners();

    await weekConfigCollection.set(item);

    //refresh the db
    await fetch();
  }

  Future<void> fetch() async {
    // Clear any existing data we have gotten previously, to avoid duplicate data
    weekConfigs.clear();

    // Indicate that we are loading
    loading = true;
    notifyListeners();  // Tell children to redraw, and they will see that the loading indicator is on

    // Get all movies
    var querySnapshot = await weekConfigCollection.get();

    // Iterate over the movies and add them to the list
    weekConfigs.addAll(querySnapshot.data());

    loading = false;
    notifyListeners();
  }
}