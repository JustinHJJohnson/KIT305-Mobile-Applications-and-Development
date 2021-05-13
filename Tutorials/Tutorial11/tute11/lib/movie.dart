import 'package:flutter/material.dart';

class Movie
{
  String title;
  int year;
  double duration;
  String image;

  Movie({ this.title, this.year, this.duration, this.image });
}

class MovieModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Movie> items = [];

  //Normally a model would get from a database here, we are just hardcoding some data for this week
  MovieModel()
  {
    add(Movie(title:"Lord of the Rings", year:2001, duration:9001, image:"https://upload.wikimedia.org/wikipedia/en/8/8a/The_Lord_of_the_Rings_The_Fellowship_of_the_Ring_%282001%29.jpg"));
    add(Movie(title:"The Matrix", year:1999, duration:150, image:"https://upload.wikimedia.org/wikipedia/en/c/c1/The_Matrix_Poster.jpg"));
  }

  /// Adds [item] to list. This and [removeAll] are the only ways to modify the
  /// cart from the outside.
  void add(Movie item) {
    items.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all items from the list.
  void removeAll() {
    items.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}