import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_photo/get_photo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _image;

  void _getImage() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: GetPhoto(
            crossAxisCount: 4,
            // showType: ShowType.all,
            lang: {
              'Recent': '所有图片',
              'Camera': '相机',
              'WeiXin': '微信',
            },
            onTap: (v) async {
              _image = await v.originBytes;
              print((await v.titleAsync));
              setState(() {});
            },
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('getPhoto demo'),
      ),
      body: Center(
        child: _image == null
            ? MaterialButton(
                onPressed: () => _getImage(),
                child: Icon(Icons.image),
                color: Colors.blue,
              )
            : Image.memory(
                _image!,
                fit: BoxFit.cover,
                width: 200.0,
              ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _getImage,
        tooltip: 'getImage',
        child: Icon(Icons.image),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
