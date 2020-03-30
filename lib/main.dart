import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './theme_provider.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(
    ChangeNotifierProvider<DynamicTheme>(
      create: (_) => DynamicTheme(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DynamicTheme>(context);
    return MaterialApp(
      theme: themeProvider.getDarkMode() ? ThemeData.dark() : ThemeData.light(),
      title: 'Image Picker',
      home: Scaffold(
        drawer: Drawer(
          elevation: 0,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Image.asset(
                  'assets/images/logo.jfif',
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 60, 140, 231),
                      Color.fromARGB(255, 0, 234, 255),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 2.0,
              ),
              ListTile(
                title: Center(
                  child: Text('CodeNameAKshay'),
                ),
                onTap: () {
                  // Navigator.pop(context);
                },
              ),
              Divider(
                height: 2.0,
              ),
              Builder(
                builder: (context) => ListTile(
                  title: Text('Toggle Dark mode'),
                  leading: Icon(Icons.brightness_4),
                  onTap: () {
                    setState(() {
                      themeProvider.changeDarkMode(!themeProvider.isDarkMode);
                    });
                    Navigator.pop(context);
                  },
                  trailing: CupertinoSwitch(
                    value: themeProvider.getDarkMode(),
                    onChanged: (value) {
                      setState(() {
                        themeProvider.changeDarkMode(value);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              Divider(
                height: 2.0,
              ),
              Builder(
                builder: (context) => ListTile(
                  leading: Icon(Icons.open_in_browser),
                  title: new InkWell(
                      child: Text('Visit my website!'),
                      onTap: () {
                        launch('http://codenameakshay.tech');
                        Navigator.pop(context);
                      }),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Divider(
                height: 2.0,
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Image Picker'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8),
              child: _image == null
                  ? Text('No Image Selected')
                  : Image.file(_image),
            ),
            ScanButton(getImageCamera, getImageGallery),
          ],
        ),
      ),
    );
  }
}

class ScanButton extends StatelessWidget {
  Function getImageCamera;
  Function getImageGallery;
  ScanButton(this.getImageCamera, this.getImageGallery);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: SizedBox(
                  height: 60,
                  child: RaisedButton(
                    onPressed: getImageCamera,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.camera_alt,
                        ),
                        Text('Scan')
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: SizedBox(
                  height: 60,
                  child: RaisedButton(
                    onPressed: getImageGallery,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.photo,
                        ),
                        Text('Gallery')
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
