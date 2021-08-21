import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  bool _tfinitialised = false;
  File _image ;
  List _output;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        // tf will initialise (load model)
        _tfinitialised = true;
      });
    });
  }

  clasifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.4,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output;
      _loading = false;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/WasteClassifier_TFL.tflite',
        labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Tflite.close();
    super.dispose();
  }

  Future pickImage() async {
    final image = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (image != null) {
        _image = File(image.path);
      } else {
        return null;
      }
    });

    clasifyImage(_image);
  }

  pickGalleryImage() async {
    final image = await picker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });

    clasifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: !_tfinitialised
          ? CircularProgressIndicator()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 50),
                  Text(
                    "Waste Classifier with TensorFlow",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),
                  Text(
                    "Classify Waste",
                    style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: _loading
                        ? Container(
                            width: 300,
                            child: Column(
                              children: <Widget>[
                                Image.asset('assets/2.jpeg'),
                                SizedBox(height: 40),
                              ],
                            ),
                          )
                        : Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 250,
                                  child: Image.file(_image),
                                ),
                                SizedBox(height: 20),
                                _output != null
                                    ? Text(
                                        '${_output[0]['label']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                              width: MediaQuery.of(context).size.width - 150,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 17),
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Take A Photo',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: pickGalleryImage,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 150,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 17),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Browse',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}