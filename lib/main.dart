
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(WahajChatApp());
}

class WahajChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WahajHome(),
    theme: ThemeData(primaryColor: Color(0xFF7C3AED)),
  );
}

class WahajHome extends StatefulWidget {
  @override
  _WahajHomeState createState() => _WahajHomeState();
}

class _WahajHomeState extends State<WahajHome>{
  var ctrl=TextEditingController();

  void send() async {
    if(ctrl.text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('messages').add({
      'text': ctrl.text,
      'time': FieldValue.serverTimestamp(),
    });
    ctrl.clear();
  }

  @override
  Widget build(BuildContext c){
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF7C3AED), title: Text("🔥 وهج شات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      body: Column(children: [
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('messages').orderBy('time').snapshots(),
          builder: (c,snap){
            if(!snap.hasData) return Center(child: Text("🔥 مرحباً في وهج شات\nابدأ محادثة", textAlign: TextAlign.center, style: TextStyle(fontSize: 22)));
            var docs = snap.data!.docs;
            if(docs.isEmpty) return Center(child: Text("🔥 مرحباً في وهج شات\nابدأ محادثة", textAlign: TextAlign.center, style: TextStyle(fontSize: 22)));
            return ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: docs.length,
              itemBuilder: (c,i){
                var data = docs[i].data() as Map;
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Color(0xFF7C3AED), borderRadius: BorderRadius.circular(12)),
                    child: Text(data['text']?? '', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            );
          },
        )),
        Container(padding: EdgeInsets.all(8), child: Row(children: [
          Expanded(child: TextField(controller: ctrl, decoration: InputDecoration(hintText: "اكتب...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)), filled: true, fillColor: Colors.grey[100]))),
          SizedBox(width: 6),
          CircleAvatar(backgroundColor: Color(0xFF7C3AED), child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: send))
        ]))
      ]),
    );
  }
}