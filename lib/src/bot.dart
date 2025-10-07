import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  var messages = <Map<String, String>>[].obs;
  var isLoading = false.obs;

  final String apiKey = "AIzaSyAr235rJSHqiFNob0Kr90gIvJ5I0tkC96o"; 
  //https://github.com/mrxdevs/baatu/blob/40116ef54cbf5900e5a91ad990fb8445aa9c9111/lib/services/gemini_service.dart
  //https://github.com/AshaniTH/Vet_Assist/tree/4b4f2fe933d4f9e234be59c45b3b276f7b46c00f
  // https://github.com/duwcston/FurEver/blob/651b5655db60b289297d549faa123c0c56caf7d8/lib/services/gemini_service.dart#L3
  //https://github.com/jmfave123/Campus-Safe-Security-WebApp/tree/79b55e5bbcc3fb48bf011b30acb3f729660e2407
  final String apiUrl ="https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=";
     

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;


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
      
        messages.add({"role": "bot", "text": "API Error: Status ${response.statusCode}, Body: ${response.body}"});
      }
    } catch (e) {
      messages.add({"role": "bot", "text": "Network Error: $e"});
    }

    isLoading.value = false;
  }
}