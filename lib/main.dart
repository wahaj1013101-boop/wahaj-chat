import 'package:flutter/material.dart';
void main()=>runApp(WahajChatApp());
class WahajChatApp extends StatelessWidget{
@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,home:WahajHome(),theme:ThemeData(primaryColor:Color(0xFF7C3AED)));
}
class WahajHome extends StatefulWidget{ @override _WahajHomeState createState()=>_WahajHomeState();}
class _WahajHomeState extends State<WahajHome>{
List<Map<String,String>> messages=[];
var ctrl=TextEditingController();
void send(){ if(ctrl.text.trim().isEmpty) return; setState((){ messages.add({"text":ctrl.text,"me":"true"}); messages.add({"text":"أهلاً في وهج شات 🔥\nرسالتك: ${ctrl.text}","me":"false"});}); ctrl.clear();}
@override Widget build(BuildContext context){ return Scaffold(appBar:AppBar(backgroundColor:Color(0xFF7C3AED),title:Text("🔥 وهج شات",style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),body:Column(children:[Expanded(child:messages.isEmpty?Center(child:Text("مرحباً في وهج شات 🔥\nابدأ محادثة",textAlign:TextAlign.center,style:TextStyle(fontSize:22))):ListView.builder(padding:EdgeInsets.all(15),itemCount:messages.length,itemBuilder:(c,i){ bool me=messages[i]["me"]=="true"; return Align(alignment:me?Alignment.centerRight:Alignment.centerLeft,child:Container(margin:EdgeInsets.symmetric(vertical:4),padding:EdgeInsets.all(12),decoration:BoxDecoration(color:me?Color(0xFF7C3AED):Colors.grey[200],borderRadius:BorderRadius.circular(12)),child:Text(messages[i]["text"]!,style:TextStyle(color:me?Colors.white:Colors.black))));})),Container(padding:EdgeInsets.all(8),child:Row(children:[Expanded(child:TextField(controller:ctrl,decoration:InputDecoration(hintText:"اكتب...",border:OutlineInputBorder(borderRadius:BorderRadius.circular(25)),filled:true,fillColor:Colors.grey[100]))),SizedBox(width:6),CircleAvatar(backgroundColor:Color(0xFF7C3AED),child:IconButton(icon:Icon(Icons.send,color:Colors.white),onPressed:send))]))]));}
}
