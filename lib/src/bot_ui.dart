import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/widgets/loading.dart';
import 'bot.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController inputController = TextEditingController();

  ChatPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text("Former Guilder")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final isUser = msg["role"] == "user";
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg["text"] ?? ""),
                      ),
                    );
                  },
                )),
          ),
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Loading(size:50),
                )
              : const SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = inputController.text;
                    inputController.clear();
                    controller.sendMessage(text);
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
}
