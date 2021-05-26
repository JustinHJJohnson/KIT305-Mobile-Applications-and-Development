import 'package:flutter/material.dart';
import 'package:flutter_tutorial_3/movie_details.kt.dart';
import 'package:provider/provider.dart';
import 'movie.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //added this line
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: _initialization,
      builder: (context, snapshot) // This function is called every time the "future" updates
      {
        // Check for errors
        if (snapshot.hasError) {
          return FullScreenText(text: "Something went wrong");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          //BEGIN: the old MyApp builder from last week
          return ChangeNotifierProvider(
              create: (context) => MovieModel(),
              child: MaterialApp(
                  title: 'Database Tutorial',
                  theme: ThemeData(
                    primarySwatch: Colors.green,
                  ),
                  home: MyHomePage(title: 'Database Tutorial')
              )
          );
          //END: the old MyApp builder from last week
        }

        return CircularProgressIndicator();
      }
    );
  }
}

class MyHomePage extends StatefulWidget
{
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage>
{
  // Code for refresh idicator from here https://protocoderspoint.com/flutter-refresh-indicator-a-pull-to-refresh-listview-with-example/#Variable_and_method_we_gonna_use
  var refreshkey = GlobalKey<RefreshIndicatorState>();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieModel>(
        builder:buildScaffold
    );
  }

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

  Scaffold buildScaffold(BuildContext context, MovieModel movieModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return MovieDetails();
          });
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            //YOUR UI HERE
            if (movieModel.loading) CircularProgressIndicator() else Expanded(
              child: RefreshIndicator(
                key: refreshkey,
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    var movie = movieModel.items[index];
                    return Dismissible(
                      key: Key(movie.title),
                      onDismissed: (DismissDirection direction) {
                        movieModel.delete(movie.id);
                        ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('${movie.title} deleted')));
                      },
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text(movie.title),
                        subtitle: Text(movie.year.toString() + " - " + movie.duration.toString() + " Minutes"),
                        leading: loadImage(movie),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) { return MovieDetails(id: movie.id); }));
                        },
                      ),
                    );
                  },
                  itemCount: movieModel.items.length
                ),
                onRefresh: () => movieModel.fetch()
              ),
            )
          ],
        ),
      ),
    );
  }
}

//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}
