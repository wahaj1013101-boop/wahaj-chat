import 'package:flutter/material.dart';

void main() {
  runApp(WahajChatApp());
}

class WahajChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wahaj Chat',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> messages = [];
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('وهج شات 💜'), backgroundColor: Colors.purple),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(messages[index]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'اكتبي رسالة...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.purple),
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        messages.add(controller.text);
                        controller.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}