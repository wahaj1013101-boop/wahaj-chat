import 'package:flutter/material.dart';
void main(){runApp(const WahajChatApp());}
class WahajChatApp extends StatelessWidget{
const WahajChatApp({super.key});
@override
Widget build(BuildContext context){
return MaterialApp(title:'Wahaj Chat',debugShowCheckedModeBanner:false,home:const ChatScreen());
}}
class ChatScreen extends StatefulWidget{
const ChatScreen({super.key});
@override
State<ChatScreen> createState()=>_ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen>{
final List<String> messages=[];
final controller=TextEditingController();
void send(){if(controller.text.trim().isEmpty)return;setState((){messages.add(controller.text);controller.clear();});}
@override
Widget build(BuildContext context){
return Scaffold(appBar:AppBar(title:const Text('Wahaj Chat - وهج')),body:Column(children:[Expanded(child:ListView.builder(padding:const EdgeInsets.all(12),itemCount:messages.length,itemBuilder:(c,i)=>Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person)),title:Text(messages[i]))))),Padding(padding:const EdgeInsets.all(8),child:Row(children:[Expanded(child:TextField(controller:controller,decoration:const InputDecoration(hintText:'اكتب رسالة...',border:OutlineInputBorder()))),IconButton(icon:const Icon(Icons.send),onPressed:send)]))]));
}}
