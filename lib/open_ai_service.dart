import 'dart:convert';

import 'package:ai_assistant/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAiService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode(
          {
            'model': 'gpt-3.5-turbo',
            "messages": [
              {
                'role': 'user',
                'content':
                    'Does this message wants to generate an AI picture, image, art or anything similar? $prompt. Simply answer with yes or no.',
              },
            ],
          },
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'Yes.':
          case 'yes.':
          case 'yes':
            final res = await dallEApi(prompt);
            return res;
          default:
            final res = await chatGptApi(prompt);
            return res;
        }
      }
      return 'An internal error occured.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGptApi(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode(
          {
            'model': 'gpt-3.5-turbo',
            "messages": messages,
          },
        ),
      );
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();
        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occured.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEApi(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode(
          {
            'prompt': prompt,
            'n': 1,
          },
        ),
      );
      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();
        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occured.';
    } catch (e) {
      return e.toString();
    }
  }
}
