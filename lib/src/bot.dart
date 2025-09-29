import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class ChatController extends GetxController {
  var messages = <Map<String, String>>[].obs;
  var isLoading = false.obs;

  final String apiKey = "AIzaSyAr235rJSHqiFNob0Kr90gIvJ5I0tkC96o"; 

final String apiUrl =
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=";
     

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // add user message
    messages.add({"role": "user", "text": text});

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse("$apiUrl$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": text}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
                "No response";

        messages.add({"role": "bot", "text": reply});
      } else {
        // Use response.statusCode for a clearer error
        messages.add({"role": "bot", "text": "API Error: Status ${response.statusCode}, Body: ${response.body}"});
      }
    } catch (e) {
      messages.add({"role": "bot", "text": "Network Error: $e"});
    }

    isLoading.value = false;
  }
}