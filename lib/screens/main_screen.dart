//GitHub Repo Link: https://github.com/shashankpathak7798/OnlineMic-Task.git////////////////////////////////

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _videoPath = '';
  int _toUpload = 0;
  bool isUploading = false;
  bool uploadSuccess = false;
  bool _recordingStarted = false;

  CameraController? _cameraController;
  VideoPlayerController? _videoPlayerController;
  Future<void>? _initializeVideoPlayerFuture;

  Future<void> compressVideo() async {
    setState(() {
      isUploading = true;
    });
    final FirebaseStorage storage = FirebaseStorage.instance;

    if (_videoPath.isEmpty) {
      return;
    }
    final videoFile = File(_videoPath);

    final info = await VideoCompress.compressVideo(
      videoFile.path,
      quality: VideoQuality.DefaultQuality,
    );

    final compressedResult = info?.file;

    final Reference reference = storage.ref().child('videos/${info!.filesize}');

    final UploadTask uploadTask = reference.putFile(compressedResult!);
    final TaskSnapshot downloadUrl = await uploadTask.whenComplete(() => null);

    final String url = await downloadUrl.ref.getDownloadURL();
    await FirebaseFirestore.instance.collection('videos').add({
      'url': url,
      'createdAt': FieldValue.serverTimestamp(),
    }).whenComplete(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Success!!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _videoPath = '';
        uploadSuccess = true;
        isUploading = false;
      });
    });
  }

  // Function to pick video from device storage.
  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      _videoPlayerController = VideoPlayerController.file(file);
      _videoPlayerController = VideoPlayerController.file(file);

      _initializeVideoPlayerFuture = _videoPlayerController?.initialize();
      _videoPlayerController?.setLooping(true);
      _videoPlayerController?.play();

      setState(() {
        _videoPath = file.path;
      });
      print('VideoPath: $_videoPath');
    }
  }

  // Function to Initialize Camera
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController =
        CameraController(camera, ResolutionPreset.high, enableAudio: true);

    await _cameraController?.initialize();
    setState(() {});
  }

  // Function to Start Video Recording
  Future<void> startRecording() async {
    try {
      setState(() {
        _videoPath = '';
        _videoPlayerController?.pause();
        _videoPlayerController = null;
        _recordingStarted = true;
      });
      await _cameraController?.startVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  // Function to Stop Video Recording
  Future<void> stopRecording() async {
    if (!_cameraController!.value.isRecordingVideo) {
      return;
    }
    _cameraController?.pausePreview();

    setState(() {
      _recordingStarted = false;
    });

    final XFile videoFile = await _cameraController!.stopVideoRecording();
    final tempDir = await getTemporaryDirectory();
    final outputFile =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');
    await videoFile.saveTo(outputFile.path);

    _videoPlayerController = VideoPlayerController.file(outputFile);
    _initializeVideoPlayerFuture = _videoPlayerController?.initialize();
    _videoPlayerController?.play();
    _videoPlayerController?.setLooping(true);

    setState(() {
      _videoPath = outputFile.path;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }



  Widget buildPreview() {

    return _recordingStarted == true ? Center(child: Text('Recording Started Please Record the video and click stop recording when done!!'),) : FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (BuildContext context,
          AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.done) {
          return AspectRatio(
            aspectRatio:
            _videoPlayerController!.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController!),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lost Less Compressor'),
        actions: [
          IconButton(
              onPressed: () => setState(() {
                    _videoPlayerController?.pause();
                    _videoPlayerController = null;
                  }),
              icon: Icon(Icons.delete))
        ],
        backgroundColor: Colors.blueAccent.withOpacity(0.5),
      ),
      backgroundColor: Colors.tealAccent.withOpacity(0.8),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Radio(
                    value: 0,
                    groupValue: _toUpload,
                    onChanged: (val) => setState(() {
                      _toUpload = 0;
                    }),
                  ),
                  Text('Upload a Video'),
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: _toUpload,
                    onChanged: (val) => setState(() {
                      _toUpload = 1;
                    }),
                  ),
                  Text('Record a Video'),
                ],
              ),
            ],
          ),
          Divider(
            thickness: 4,
            color: Colors.deepPurple.withOpacity(0.5),
            indent: 10,
            endIndent: 10,
          ),
          Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                width: double.infinity,
                height: 400,
                child: _videoPlayerController == null
                    ? Center(
                        child: Text('Please Upload or Record a Video!!'),
                      )
                    : buildPreview(),
              ),
              if (isUploading)
                Container(
                    width: double.infinity,
                    height: 400,
                    color: Colors.white24,
                    child: Center(
                        child: Container(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator()))),
            ],
          ),
          Divider(
            thickness: 3,
            color: Colors.deepPurple.withOpacity(0.5),
            indent: 10,
            endIndent: 10,
          ),
          if (_toUpload == 0)
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Pick Video!,'),
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(15),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.withOpacity(0.8),),
                side: MaterialStateProperty.all<BorderSide>(BorderSide(width: 0.5, style: BorderStyle.solid,),),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
              ),
            ),
          if (_toUpload == 1)
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: startRecording,
                    label: Text('Start Recording'),
                    icon: Icon(Icons.play_arrow),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(15),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.withOpacity(0.8),),
                      side: MaterialStateProperty.all<BorderSide>(BorderSide(width: 0.5, style: BorderStyle.solid,),),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: stopRecording,
                    label: Text('Stop Recording'),
                    icon: Icon(Icons.pause),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(15),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.withOpacity(0.8),),
                      side: MaterialStateProperty.all<BorderSide>(BorderSide(width: 0.5, style: BorderStyle.solid,),),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => compressVideo(),
                icon: Icon(Icons.upload),
                label: Text('Compress&Upload'),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(15),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.withOpacity(0.8),),
                  side: MaterialStateProperty.all<BorderSide>(BorderSide(width: 0.5, style: BorderStyle.solid,),),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
