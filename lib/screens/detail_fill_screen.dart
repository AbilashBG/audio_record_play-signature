import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';

class DetailsPage extends StatefulWidget {
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  String? _vehicleRegNo;
  String? _model;
  String? _customerName;
  String? _mobileNo;
  String? _selectedView;
  File? _imageFile;
  String? _recordedFilePath;
  String? _tempPath;
  final List<String> _views = ['Right', 'Left', 'Front', 'Rear', 'Interior'];
  final picker = ImagePicker();
  FlutterSoundRecorder? _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  AudioPlayer audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.red,
  );

  @override
  void initState() {
    super.initState();
    _initPaths();
    _initAudioRecorder();
  }

  void _initPaths() async {
    final tempDir = await getTemporaryDirectory();
    _tempPath = tempDir.path;
  }

  void _initAudioRecorder() async {
    /// Request permission to record audio
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      /// Permission granted, initialize audio recorder
      await _audioRecorder!.openRecorder();
    } else {
      /// Permission denied, show message to the user
      Fluttertoast.showToast(
        msg: "Permission to record audio denied",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _audioRecorder!.closeRecorder();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Pickup Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    _vehicleRegNo = value;
                    if (value == 'TN10BK1234') {
                      _model = 'ABC Model';
                      _customerName = 'Kumar';
                      _mobileNo = '1234567890';
                    } else if (value == 'TN20BK4873') {
                      _model = 'XYZ Model';
                      _customerName = 'Ravi';
                      _mobileNo = '9876543210';
                    } else {
                      _model = null;
                      _customerName = null;
                      _mobileNo = null;
                    }
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Enter Vehicle Registration Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Model: ${_model ?? ''}'),
              Text('Customer Name: ${_customerName ?? ''}'),
              Text('Mobile Number: ${_mobileNo ?? ''}'),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedView,
                items: _views.map((String view) {
                  return DropdownMenuItem<String>(
                    value: view,
                    child: Text(view),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedView = newValue;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select View',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 130,
                width: size.width,
                child: Row(
                  children: [
                    _imageFile != null
                        ? Container(
                      height: 130,
                      width: 130,
                      color: Colors.red,
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const SizedBox(),
                    InkWell(
                      onTap: _capturePhoto,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 13,
                        ),
                        height: 130,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            13,
                          ),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 43,
                            ),
                            Text(
                              "Capture Image",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: IconButton(
                      onPressed: _toggleRecording,
                      icon: Icon(
                        _isRecording ? Icons.mic_off : Icons.mic,
                        size: 30,
                        color: _isRecording ? Colors.red : Colors.black,
                      ),
                      color: Colors.indigo,
                    ),
                  ),
                  _recordedFilePath != null
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying?Icons.pause:Icons.play_arrow_rounded),
                        onPressed: () {
                          if (!_isPlaying) {
                            _playRecordedAudio(_recordedFilePath!);
                          } else {
                            _pauseAudio();
                          }
                        },
                      ),
                    ],
                  )
                      : SizedBox(),
                ],
              ),
              const SizedBox(height: 20),
              /// Display the recorded audio file path below the button
              _recordedFilePath != null
                  ? Text(
                'Recorded Audio Path: $_recordedFilePath',
                style: TextStyle(color: Colors.green),
              )
                  : SizedBox(),
              const SizedBox(height: 20),
              Text("Signature",style: TextStyle(
                fontSize: 19,
              ),),
              SizedBox(height: 13,),
              Container(
                height: 130,
                width: size.width,
              decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey,),
              ),
                child: Signature(
                  controller: _signatureController,
                  height: 130,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  if (_vehicleRegNo != null &&
                      _model != null &&
                      _customerName != null &&
                      _mobileNo != null &&
                      _selectedView != null) {
                    /// Form is valid, submit the data
                    Map<String, dynamic> formData = {
                      'vehicleregno': _vehicleRegNo,
                      'model': _model,
                      'customername': _customerName,
                      'mobileno': _mobileNo,
                      'view': _selectedView,
                      'imageFile':
                      _imageFile != null ? _imageFile?.path : null,
                      'recordedAudioPath': _recordedFilePath,
                      'signature': _signatureController.toPngBytes(),
                    };
                    Fluttertoast.showToast(
                      msg: "Form Submitted successfully",
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.green,
                    );
                  } else {
                    print('Please fill all the fields');
                    Fluttertoast.showToast(
                      msg: "Please fill all the fields",
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                    );
                  }
                },
                child: Container(
                  height: 60,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() async {
    if (!_isRecording) {
      /// Pause audio playback if it's currently playing
      await audioPlayer.pause();

      setState(() {
        _recordedFilePath = null;
        _isRecording = true;
      });
      await _audioRecorder!.startRecorder(
        toFile: '$_tempPath/audio_recording.aac',
        codec: Codec.aacMP4,
      );
    }
  }

  void _stopRecording() async {
    if (_isRecording) {
      await _audioRecorder!.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFilePath =
        '$_tempPath/audio_recording.aac';
      });
    }
  }

  Future<void> _capturePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// Method to play recorded audio
  /// Function to play recorded audio
  Future<void> _playRecordedAudio(String filePath) async {
    try {
      setState(() {
        _isPlaying = true;
      });

      File audioFile = File(filePath);

      if (await audioFile.exists()) {
        DeviceFileSource audioSource = DeviceFileSource(filePath);
        await audioPlayer.play(audioSource);

        /// Listen to audio player's completion event to change the icon back to play
        audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            _isPlaying = false;
          });
        });

        print('Audio played successfully');
      } else {
        print('Error: Audio file does not exist');
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }


  /// Method to pause audio playback
  Future<void> _pauseAudio() async {
    try {
      await audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }
}
