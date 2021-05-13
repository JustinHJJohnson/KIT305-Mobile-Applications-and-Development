import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'movie.dart';
import 'movie_details.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MovieModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'List Tutorial'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieModel>(
      builder:buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, MovieModel movieModel, _) {
    return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          //YOUR UI HERE
          Expanded(
            child: ListView.builder(
                itemBuilder: (_, index) {
                  var movie = movieModel.items[index];
                  return ListTile(
                      title:Text(movie.title),
                      subtitle: Text(movie.year.toString() + " - " + movie.duration.toString() + " Hours"),
                      leading: movie.image != null ? Image.network(movie.image) : null,
                    onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) { return MovieDetails(id:index); }));
                    }
                  );
                },
              itemCount:movieModel.items.length
            ),
          )

        ],
      ),
    ),
  );
  }
}