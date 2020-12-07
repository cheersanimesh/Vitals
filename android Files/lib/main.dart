import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_sharing/video_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:transparent_image/transparent_image.dart';

import 'chewie_player.dart';
import 'apis/firebase_provider.dart';
import 'apis/publitio_provider.dart';
import 'package:http/http.dart' as http;
import 'result.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vitals App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Test Platform'),
      routes: {
        '/getResults': (context) => Result(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<VideoInfo> _videos = <VideoInfo>[];
  bool _imagePickerActive = false;
  bool _uploading = false;
  String serverURL="http://99782961c5e1.ngrok.io/";
  String serverURL2="http://99782961c5e1.ngrok.io/getVal";
  @override
  void initState() {
    PublitioProvider.configurePublitio();
    //FirebaseProvider.listenToVideos((newVideos) {
        //_videos = newVideos;
      //});
    super.initState();
  }
  Future<http.Response> sendRequest(String link,int mode,String sUrl)
  {
    return http.post(
        sUrl,
        body: jsonEncode(<String,String>{
          'mode': "0",
          'link':link,
        }),
    );
  }
  void _takeVideo() async {
    if (_imagePickerActive) return;

    _imagePickerActive = true;
    final File videoFile =
    await ImagePicker.pickVideo(source: ImageSource.camera);
    _imagePickerActive = false;

    if (videoFile == null) return;

    setState(() {
      _uploading = true;
    });

    try {
      final video = await PublitioProvider.uploadVideo(videoFile);
      //await FirebaseProvider.saveVideo(video);
    } on PlatformException catch (e) {
      print('${e.code}: ${e.message}');
      //result = 'Platform Exception: ${e.code} ${e.details}';
    } finally {
      setState(() {
        _uploading = false;
      });
    }
    //var response = await http.post(serverURL,body:{'link':});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _videos.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChewiePlayer(
                            video: _videos[index],
                          );
                        },
                      ),
                    );
                    */
                    print(_videos[index].videoUrl);
                    var response = await http.post(serverURL,body:{'mode':0,'link':_videos[index].videoUrl});
                    var response2= await http.post(serverURL2,body:{'mode':1});
                    print(response);
                    print("hello world");
                    print(response2);
                    sendRequest(_videos[index].videoUrl, 0, serverURL);
                  },
                  child: Card(
                    child: new Container(
                      padding: new EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Center(child: CircularProgressIndicator()),
                              Center(
                                child: ClipRRect(
                                  borderRadius: new BorderRadius.circular(8.0),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: _videos[index].thumbUrl,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 20.0)),
                          ListTile(
                            title: Text(_videos[index].videoUrl),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
          child: _uploading
              ? CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : Icon(Icons.add),
          onPressed:() {
            _takeVideo();

          },
    ),
    );
    }
  }