import 'package:flutter/cupertino.dart';

class Movie 
{
  String title;
  int year;
  double duration;
  String image;
  
  Movie({ this.title, this.year, this.duration, this.image });
}

class MovieModel extends ChangeNotifier {
  final List<Movie> items = [];

  MovieModel()
  {
    add(Movie(title:"Lord of the Rings", year:2001, duration:9001, image:"https://upload.wikimedia.org/wikipedia/en/8/8a/The_Lord_of_the_Rings_The_Fellowship_of_the_Ring_%282001%29.jpg"));
    add(Movie(title:"Crab", year:1999, duration:150, image:"https://media.giphy.com/media/457HrZvJ5IIQSXweiO/giphy.gif"));
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

  void remove(Movie item){
    items.removeWhere((element) => element.title == item.title);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}

