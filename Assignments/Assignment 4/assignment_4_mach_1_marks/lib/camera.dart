import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//1. import for camera
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';

//add for download/upload
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

//add these for web
import 'package:http/http.dart' as http;
import 'dart:convert';

//https://firebase.flutter.dev/docs/storage/usage/
//https://medium.com/codechai/uploading-image-to-firebase-storage-in-flutter-app-android-ios-31ddd66843fc
//https://ptyagicodecamp.github.io/loading-image-from-firebase-storage-in-flutter-app-android-ios-web.html
// This code is a heavily brutalised version of Lindsay Wells flutter camera example

class UploadImage {
  Future<String> androidIOSUpload(BuildContext context) async
  {
    // 2. Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    //use the TakePictureScreen to get an image. This is like doing a startActivityForResult
    var imageURL = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(
              // Pass the appropriate camera to the TakePictureScreen widget.
                camera: firstCamera
            )
        )
    );

    return imageURL;
  }

  void webUpload() async
  {
    //https://stackoverflow.com/questions/59546381/how-to-get-image-from-url-to-a-file-in-flutter
    final http.Response responseData = await http.get(Uri.parse(
        "https://pbs.twimg.com/media/Ct-BV8PVIAAnS2b?format=jpg&name=large"));
    var uint8list = responseData.bodyBytes.toList();
    var base64 = "data:image/jpeg;base64," + base64Encode(uint8list);
    try {
      await FirebaseStorage.instance
          .ref('images/hello-world' + DateTime
          .now()
          .millisecondsSinceEpoch
          .toString() + '.jpeg')
          .putString(base64, format: PutStringFormat.dataUrl);
    } on FirebaseException catch (e) {
      print("Failed to upload Web Image, error: $e");
    }
  }
}


//------------------------------------------
//camera example follows:
//------------------------------------------

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool uploading;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    uploading = false;
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: uploading ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors. black),) :Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            _controller.setFlashMode(FlashMode.off);
            _controller.stopImageStream();
            final image = await _controller.takePicture();
            final picture = File(image?.path);

            // given feedback to the user that the image is uploading
            setState(() {
              uploading = true;          
            });

            String imageURL = 'images/hello-world' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';

            // upload the image
            try {
              await FirebaseStorage.instance
                  .ref(imageURL)
                  .putFile(picture);
            } on FirebaseException catch (e) {
              print("Failed to upload image from camera, error: $e");
            }

            setState(() {
              uploading = false;          
            });

            Navigator.pop(context, imageURL);
            return;
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}