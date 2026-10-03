import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WahajChatApp());
}

class WahajChatApp extends StatelessWidget {
  const WahajChatApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wahaj Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (c, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasData) return const UsersListScreen();
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  Future<void> submit() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) return;
    setState(() => loading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailCtrl.text.trim(), password: passCtrl.text.trim());
      } else {
        var cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(), password: passCtrl.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'uid': cred.user!.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF00695C), Color(0xFF26A69A)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.chat_bubble, size: 60, color: Color(0xFF00695C)),
                    const SizedBox(height: 10),
                    const Text('Wahaj Chat', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const Text('دردشة خاصة بين شخصين', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    if (!isLogin)
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسمك', border: OutlineInputBorder())),
                    if (!isLogin) const SizedBox(height: 12),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'الإيميل', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة السر', border: OutlineInputBorder())),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading? null : submit,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C), padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text(loading? '...' : (isLogin? 'دخول' : 'إنشاء حساب'), style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    TextButton(onPressed: () => setState(() => isLogin =!isLogin), child: Text(isLogin? 'ليس لديك حساب؟ سجل' : 'لديك حساب؟ دخول')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Wahaj Chat'), backgroundColor: const Color(0xFF00695C), foregroundColor: Colors.white,
        actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))]),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (c, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          var users = snap.data!.docs.where((d) => d.id!= myUid).toList();
          if (users.isEmpty) return const Center(child: Text('لا يوجد مستخدمين بعد\nشارك التطبيق مع صديقك'));
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (c, i) {
              var u = users[i].data() as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(backgroundColor: const Color(0xFF00695C), child: Text((u['name']?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
                title: Text(u['name']?? u['email']),
                subtitle: Text(u['email']),
                trailing: const Icon(Icons.chat),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(otherUserId: u['uid'], otherUserName: u['name']?? u['email']))),
              );
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  const ChatScreen({super.key, required this.otherUserId, required this.otherUserName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final msgCtrl = TextEditingController();
  String get chatId {
    final myId = FirebaseAuth.instance.currentUser!.uid;
    var ids = [myId, widget.otherUserId]..sort();
    return ids.join('_');
  }

  void send() {
    if (msgCtrl.text.trim().isEmpty) return;
    FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'text': msgCtrl.text.trim(),
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'time': FieldValue.serverTimestamp(),
    });
    msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName), backgroundColor: const Color(0xFF00695C), foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('time').snapshots(),
              builder: (c, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                var msgs = snap.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: msgs.length,
                  itemBuilder: (c, i) {
                    var m = msgs[i].data() as Map<String, dynamic>;
                    bool isMe = m['senderId'] == FirebaseAuth.instance.currentUser!.uid;
                    return Align(
                      alignment: isMe? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe? const Color(0xFF00695C) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(m['text']?? '', style: TextStyle(color: isMe? Colors.white : Colors.black87)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: msgCtrl, decoration: const InputDecoration(hintText: 'اكتب رسالة...', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12)))),
                  const SizedBox(width: 8),
                  CircleAvatar(backgroundColor: const Color(0xFF00695C), child: IconButton(onPressed: send, icon: const Icon(Icons.send, color: Colors.white))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
