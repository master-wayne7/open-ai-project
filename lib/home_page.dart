import 'package:ai_assistant/features_box.dart';
import 'package:ai_assistant/open_ai_service.dart';
import 'package:ai_assistant/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final flutterTTS = FlutterTts();
  final SpeechToText speechToText = SpeechToText();
  String _lastWords = '';
  final OpenAiService openAiService = OpenAiService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initFlutterTTS();
  }

  Future<void> initFlutterTTS() async {
    await flutterTTS.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(
      onResult: onSpeechResult,
    );
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTTS.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTTS.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            "AI Assistant",
          ),
        ),
        centerTitle: true,
        leading: const Icon(
          Icons.menu,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // assistant's pic
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      margin: const EdgeInsets.only(
                        top: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 103,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/virtualAssistant.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ).copyWith(
                    top: 20,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ).copyWith(
                      topLeft: const Radius.circular(
                        0,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Text(
                      generatedContent ?? "Greetings. What can I do for you?",
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  child: Image.network(
                    generatedImageUrl!,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(
                    10,
                  ),
                  margin: const EdgeInsets.only(
                    top: 5,
                    left: 22,
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Here are few things you can do:',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // features lists
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeaturesBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'Chat Gpt',
                      descriptionText:
                          'A smarter way to stay organised and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(
                      milliseconds: start + delay,
                    ),
                    child: const FeaturesBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(
                      milliseconds: start + 2 * delay,
                    ),
                    child: const FeaturesBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(
          milliseconds: start + 3 * delay,
        ),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAiService.isArtPromptApi(_lastWords);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedContent = speech;
                generatedImageUrl = null;
                await systemSpeak(speech);
                setState(() {});
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}
