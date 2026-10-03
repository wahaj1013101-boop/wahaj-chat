import 'package:flutter/material.dart';

void main() {
  runApp(const WahajChatApp());
}

class WahajChatApp extends StatelessWidget {
  const WahajChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wahaj Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<String> messages = [];
  final TextEditingController controller = TextEditingController();

  void sendMessage() {
    if (controller.text.trim().isEmpty) return;
    setState(() {
      messages.add(controller.text.trim());
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wahaj Chat 💬"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (c, i) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(messages[i], style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "اكتبي رسالة...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (v) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(onPressed: sendMessage, icon: const Icon(Icons.send, color: Colors.deepPurple))
              ],
            ),
          )
        ],
      ),
    );
  }
}