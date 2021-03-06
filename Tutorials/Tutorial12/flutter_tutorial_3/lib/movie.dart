import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Movie
{
  String id;
  String title;
  int year;
  num duration;
  String image;

  Movie({this.title, this.year, this.duration, this.image});
  Movie.fromJson(Map<String, dynamic> json)
  :
  title = json['title'],
        year = json['year'],
        duration = json['duration'];

  Map<String, dynamic> toJson() =>
      {
        'title': title,
        'year': year,
        'duration' : duration
      };
}


class MovieModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Movie> items = [];

  CollectionReference moviesCollection = FirebaseFirestore.instance.collection("movies");

  bool loading = false;

  //Normally a model would get from a database here, we are just hardcoding some data for this week
  MovieModel() {
    //add(Movie(title:"Lord of the Rings", year:2001, duration:9001, image:"https://upload.wikimedia.org/wikipedia/en/8/8a/The_Lord_of_the_Rings_The_Fellowship_of_the_Ring_%282001%29.jpg"));
    //add(Movie(title:"The Matrix", year:1999, duration:150, image:"https://upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg"));
    fetch();
  }

  void add(Movie item) async {
    loading = true;
    notifyListeners();

    await moviesCollection.add(item.toJson());

    // Refresh db
    await fetch();
  }

  void update(String id, Movie item) async {
    loading = true;
    notifyListeners();

    await moviesCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }

  void delete(String id) async {
    loading = true;
    notifyListeners();

    await moviesCollection.doc(id).delete();

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
    var querySnapshot = await moviesCollection.orderBy("title").get();

    // Iterate over the movies and add them to the list
    querySnapshot.docs.forEach((doc) {
      // Note not using the add(Movie item) function, because we don't want to add them to the db
      var movie = Movie.fromJson(doc.data());
      movie.id = doc.id;
      items.add(movie);
    });

    //put this line in to artificially increase the load time, so we can see the loading indicator (when we add it in a few steps time)
    //comment this out when the delay becomes annoying
    await Future.delayed(Duration(seconds: 2));

    //we're done, no longer loading
    loading = false;
    notifyListeners();
  }

  Movie get(String id) {
    if (id == null) return null;
    return items.firstWhere((movie) => movie.id == id);
  }
}