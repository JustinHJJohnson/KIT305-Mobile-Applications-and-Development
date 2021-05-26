import 'package:flutter/material.dart';
import 'package:flutter_tutorial_2/movie_details.dart';
import 'package:provider/provider.dart';
import 'movie.dart';

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
          primarySwatch: Colors.green,
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
  // Check if the movie has an image, if it does load it with a placeholder spinning progress bar
  // loadingBuilder from here: https://www.kindacode.com/article/flutter-image-loading-builder-example/
  Widget loadImage(Movie movie)
  {
    if (movie.image == null) return null;
    return Image.network(
      movie.image,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return CircularProgressIndicator();
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieModel>(
      builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, MovieModel movieModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {movieModel.removeAll();},
              child: Icon(Icons.delete_forever),
            )
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  var movie = movieModel.items[index];
                  return Dismissible(
                    key: Key(movie.title),
                    onDismissed: (DismissDirection direction) {
                      movieModel.remove(movie);
                      ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('${movie.title} deleted')));
                    },
                    direction: DismissDirection.endToStart,
                    background: Container(color: Colors.red),
                    child: ListTile(
                      title: Text(movie.title),
                      subtitle: Text(movie.year.toString() + " - " + movie.duration.toString() + " Hours"),
                      leading: loadImage(movie),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) { return MovieDetails(id: index); }));
                      },
                    ),
                  );
                },
                itemCount: movieModel.items.length,
              )
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) { return MovieDetails(id: -1); }));
        },
      ),
    );
  }
}