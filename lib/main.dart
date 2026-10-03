import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(WahajChatApp());
}

class WahajChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wahaj Chat',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return ChatScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  String error = '';

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
    } catch (e) {
      // لو ما عندو حساب يعمل حساب جديد
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passController.text.trim(),
        );
      } catch (e2) {
        setState(() => error = 'خطأ: ${e2.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble, size: 80, color: Colors.purple),
            SizedBox(height: 16),
            Text('وهج شات 💜', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple)),
            SizedBox(height: 32),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'الإيميل', border: OutlineInputBorder())),
            SizedBox(height: 12),
            TextField(controller: passController, obscureText: true, decoration: InputDecoration(labelText: 'كلمة السر', border: OutlineInputBorder())),
            SizedBox(height: 16),
            ElevatedButton(onPressed: login, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, minimumSize: Size(double.infinity, 50)), child: Text('دخول / تسجيل جديد', style: TextStyle(color: Colors.white))),
            if (error.isNotEmpty) Padding(padding: EdgeInsets.only(top: 12), child: Text(error, style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  void sendMessage() {
    if (controller.text.trim().isNotEmpty) {
      firestore.collection('messages').add({
        'text': controller.text.trim(),
        'email': auth.currentUser?.email,
        'time': FieldValue.serverTimestamp(),
      });
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('وهج شات'),
        backgroundColor: Colors.purple,
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut())],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return ListTile(
                      title: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.purple[100], borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(msg['email']?? '', style: TextStyle(fontSize: 11, color: Colors.purple)),
                            Text(msg['text']?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: 'اكتبي رسالة', border: OutlineInputBorder()))),
                IconButton(icon: Icon(Icons.send, color: Colors.purple), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
