import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechPage extends StatefulWidget {
  const SpeechPage({super.key});

  @override
  State<SpeechPage> createState() => _SpeechPageState();
}

class _SpeechPageState extends State<SpeechPage> {
  String _wordsSpoken = "";
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();

    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Speech To Text"),
        actions: [
          Container(
            child: TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _wordsSpoken));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Text copy to clipboard')),
                  );
                },
                child: Icon(Icons.copy)),
          )
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                _speechToText.isListening
                    ? "Listening..."
                    : _speechEnabled
                        ? "Tap the microphone to record..."
                        : "Speech not available",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _wordsSpoken,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
              ),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        tooltip: "Listen",
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
        backgroundColor: Color.fromARGB(255, 60, 138, 255),
      ),
    );
  }
}
