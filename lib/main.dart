import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './theme_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
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
  final GlobalKey<State<StatefulWidget>> shareWidget = GlobalKey();
  final GlobalKey<State<StatefulWidget>> pickWidget = GlobalKey();
  final GlobalKey<State<StatefulWidget>> previewContainer = GlobalKey();
  Printer selectedPrinter;
  PrintingInfo printingInfo;
  File _image;
  File _tempImage;
  final pdf = pw.Document();
  int index;

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (_image == null) {
        _image = image;
      } else {
        _tempImage = _image;
        _image = image;
      }
    });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (_image == null) {
        _image = image;
      } else {
        _tempImage = _image;
        _image = image;
      }
    });
  }

  void createPDF(File _image) async {
    final image = PdfImage.file(
      pdf.document,
      bytes: _image.readAsBytesSync(),
    );
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          ); // Center
        }));
    final output = await getExternalStorageDirectory();
    print("${output.path}/example.pdf");
    final file = File("${output.path}/Document$index.pdf");
    index = index + 1;
    await file.writeAsBytes(pdf.save());
    // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => pdf.save());
    //   await Printing.sharePdf(bytes: pdf.save(), filename: 'my-document.pdf');
  }

  // void savePDF() async {
  //   final output = await getExternalStorageDirectory();
  //   // print(output[0]);
  //   print("${output.path}/example.pdf");
  //   final file = File("${output.path}/example.pdf");
  //   // await file.writeAsBytes(pdf.save());
  //   // await Printing.layoutPdf(
  //   //     onLayout: (PdfPageFormat format) async => pdf.save());
  //   await Printing.sharePdf(bytes: pdf.save(), filename: 'my-document.pdf');
  // }
  Future<void> _printPdf() async {
    print('Print ...');
    try {
      final bool result = await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
      _showPrintedToast(result);
    } catch (e) {
      final ScaffoldState scaffold = Scaffold.of(shareWidget.currentContext);
      scaffold.showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
    }
  }

  @override
  void initState() {
    Printing.info().then((PrintingInfo info) {
      setState(() {
        printingInfo = info;
        index = 1;
      });
    });
    super.initState();
  }

  void _showPrintedToast(bool printed) {
    final ScaffoldState scaffold = Scaffold.of(shareWidget.currentContext);
    if (printed) {
      scaffold.showSnackBar(const SnackBar(
        content: Text('Document printed successfully'),
      ));
    } else {
      scaffold.showSnackBar(const SnackBar(
        content: Text('Document not printed'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DynamicTheme>(context);
    return MaterialApp(
      theme: themeProvider.getDarkMode() ? ThemeData.dark() : ThemeData.light(),
      title: 'Image Picker',
      home: RepaintBoundary(
        key: previewContainer,
        child: Scaffold(
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
            actions: <Widget>[
              _image == null
                  ? _tempImage == null
                      ? Container()
                      : IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: () {
                            createPDF(_tempImage);
                            printingInfo.canPrint ? _printPdf() : () {};
                          },
                        )
                  : IconButton(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: () {
                        createPDF(_image);
                        printingInfo.canPrint ? _printPdf() : () {};
                      },
                    )
            ],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                child: _image == null
                    ? _tempImage == null
                        ? SizedBox(
                            height: 500,
                            child: Center(child: Text('No Image Selected')))
                        : SizedBox(height: 500, child: Image.file(_tempImage))
                    : SizedBox(height: 500, child: Image.file(_image)),
              ),
              ScanButton(getImageCamera, getImageGallery),
            ],
          ),
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
