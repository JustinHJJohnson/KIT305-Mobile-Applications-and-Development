import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'movie.dart';

class MovieDetails extends StatefulWidget {
  final int id;

  const MovieDetails({Key key, this.id}) : super(key: key);
  
  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final yearController = TextEditingController();
  final durationController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    var movies = Provider.of<MovieModel>(context, listen:false).items;
    var movie = widget.id == -1 ? Movie(title: "", year: 0, duration: 0) : movies[widget.id];

    titleController.text = movie.title;
    yearController.text = movie.year.toString();
    durationController.text = movie.duration.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Movie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: "Title"),
                      controller: titleController,
                      autofocus: true,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Year"),
                      controller: yearController,
                      autofocus: true,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Duration"),
                      controller: durationController,
                      autofocus: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(onPressed: () {
                        if (_formKey.currentState.validate())
                        {
                          movie.title = titleController.text;
                          movie.year = int.parse(yearController.text); //good code would validate these
                          movie.duration = double.parse(durationController.text); //good code would validate these

                          if (widget.id == -1)
                          {
                            Provider.of<MovieModel>(context, listen: false).add(movie);
                          }
                          else
                          {
                            Provider.of<MovieModel>(context, listen: false).notifyListeners();
                          }
                          
                          Navigator.pop(context);
                        }
                      }, icon: Icon(Icons.save), label: Text("Save Values"),),
                    )
                  ],
                ),
              ),
            )
          ]
        )
      ),
    );
  }
}