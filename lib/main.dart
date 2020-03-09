import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

void main() => runApp(MyApp());

Future<String> fetchText() async {
  var url = 'https://lt-nlgservice.herokuapp.com/rest/english/realise?subject=dog&verb=eat&object=watter&tense=past&progressive=progressive&festesmerkmal=tense,progressive';
  var response = await http.get(url,);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  return response.body;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum TtsState { playing, stopped }

class _MyAppState extends State<MyApp> {
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;

  TextEditingController _ttsController = TextEditingController();

  String _newVoiceText;

  String displayText = 'Please Press Play!';

  String _prevText = '';
  String entireText = '';

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _getLanguages();

    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _speak(String word) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        setState(() {
          displayText = word;
        });
        var result = await flutterTts.speak(word);

        if (result == 1) setState(() => ttsState = TtsState.playing);
        setState(() {
          _prevText = displayText;
        });
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in languages) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Minerva', style: TextStyle(fontWeight: FontWeight.bold),),
              backgroundColor: Colors.pink[100],
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  _inputSection(),
                  _btnSection(),
                  languages != null ? _languageDropDownSection() : Text(""),
                  _buildSliders()
                ]))));
  }

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: TextField(
        controller: _ttsController,
      ));

  Widget _btnSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop)
      ]));

  Widget _languageDropDownSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(),
          onChanged: changedLanguageDropDownItem,
        )
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () async {
                setState(() {
                  _newVoiceText = _ttsController.text;
                });
                print(_newVoiceText);
                for (int i = 0; i < _newVoiceText.split(" ").length; i++) {
                  print(_newVoiceText.split(" ")[i]);
                  await Future.delayed(Duration(milliseconds: 500), () {
                    func(_newVoiceText.split(" ")[i]);
                  });
                  if(i==_newVoiceText.split(" ").length-1){
                   entireText = _newVoiceText;
                  }
                }
              }),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  Widget _buildSliders() {
    return Column(
      children: [
        _volume(), _pitch(), _rate(), _slider(),
        FlatButton(
          color: Colors.grey[200],
          child: Text('Get some text', style: TextStyle(fontSize: 20),),
          padding: EdgeInsets.all(20),
          onPressed: (){
            fetchText().then((t){
              print(t);
              setState(() {

                _newVoiceText = t;
              });
              print('ss $_newVoiceText');
            });
          },
        ),
      ],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        activeColor: Colors.pink[100],
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.grey[400],
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.black38,
    );
  }

  CarouselSlider _slider() {
    if(entireText==''){
      return  CarouselSlider(
          height: 200.0,
          items: [_prevText, displayText].map((i) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width/2,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(),
                  child: Center(
                    child: Text(
                      '$i',
                      style: TextStyle(fontSize: 46.0, fontWeight: FontWeight.bold,color: Colors.grey[700]),
                    ),
                  ),
                );
              },
            );
          }).toList());
    } else {
      return CarouselSlider(
          height: 200.0,
          viewportFraction: 0.4,
          items: _newVoiceText.split(" ").map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(),
              child: Center(
                child: Text(
                  '$i',
                  style: TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold,color: Colors.grey[700]),
                ),
              ),
            );
          },
        );
      }).toList());
    }
  }
}
