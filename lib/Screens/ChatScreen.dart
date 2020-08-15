import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didicodes/Widgets/ImageWidget.dart';
import 'package:didicodes/Widgets/ProgressIndicator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverAvatar;

 ChatScreen({Key key, 
  @required this.receiverId, 
  @required this.receiverAvatar}) : super(key : key);

  @override
  State createState() => ChatScreenState(
    receiverAvatar: receiverAvatar, 
    receiverId: receiverId
    );
}

class ChatScreenState extends State<ChatScreen> {
  final String receiverId;
  final String receiverAvatar;

 ChatScreenState({Key key, 
 @required this.receiverId, 
 @required this.receiverAvatar});

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listscrollcontroller = ScrollController();
  final FocusNode focusNode = FocusNode();
  // ignore: non_constant_identifier_names
  bool DisplaySticker;
  bool isLoading;
  File imageFile;
  String imageUrl;
  String chatId;
  SharedPreferences preferences;
  String id;
  var listMessage;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    DisplaySticker = false;
    isLoading = false;
    chatId = "";
    readLoacal();
  }

 void onFocusChange(){
  if(focusNode.hasFocus){
  setState(() {
    DisplaySticker = false;
  });
}
  }

  

  readLoacal() async{
    preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id") ?? "";

    if(id.hashCode <= receiverId.hashCode){
      chatId = "$id-$receiverId";
    }
    else{
      chatId = "$receiverId-$id";
    }
    Firestore.instance.collection("users").document(id).updateData({'chattingWith': receiverId});
    setState(() {
      
    });

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
          //Create List Of Messages
          createListMessages(),
          //show Stickers
          (DisplaySticker ? createSticker() : Container()),
            //InputControllers
          createInputs(),
            ],
          ),
          createLoading(),
        ],
      ),
    );
  }

  createLoading(){
    return Positioned(
      child: isLoading ? circularProgress() : Container()
    );
  }
  Future<bool> onBackPress(){
    if(DisplaySticker){
      setState(() {
        DisplaySticker = false;
      });
    }
    else{
      Navigator.pop(context);
    }
    return Future.value(false);
  }
  createSticker(){
    return Container(
      child:Column(
        children: <Widget>[

          Row(
            children: <Widget>[            
          FlatButton(
            onPressed: (){
            SendMessage("MyEmoji1", 2);
            }, 
          child: Image.asset("assets/MyEmoji1.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          ),
          ),

          
          FlatButton(
            onPressed: (){
              SendMessage("MyEmoji2", 2);
            }, 
          child: Image.asset("assets/MyEmoji2.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          ),
          ),
          FlatButton(
            onPressed: (){
              SendMessage("MyEmoji3.gif", 2);
            }, 
          child: Image.asset("assets/MyEmoji3.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          )
          )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          
          Row(
            children: <Widget>[
          FlatButton(
            onPressed: (){
            SendMessage("MyEmoji4", 2);
            }, 
          child: Image.asset("assets/MyEmoji4.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          ),
          ),

          
          FlatButton(
            onPressed: (){
              SendMessage("MyEmoji5", 2);
            }, 
          child: Image.asset("assets/MyEmoji5.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          ),
          ),

          
          FlatButton(
            onPressed: (){
              SendMessage("MyEmoji6", 2);
            }, 
          child: Image.asset("assets/MyEmoji6.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          )
          )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          
         Row(
            children: <Widget>[
            
          FlatButton(
            onPressed: (){
            SendMessage("MyEmoji7", 2);
            }, 
          child: Image.asset("assets/MyEmoji7.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          ),
          ),

          
          FlatButton(
            onPressed: (){
              SendMessage("MyEmoji8", 2);
            }, 
          child: Image.asset("assets/MyEmoji8.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          ),
          ),

          
          FlatButton(
            onPressed: (){
              SendMessage("MyEmoji9", 2);
            }, 
          child: Image.asset("assets/MyEmoji9.gif",
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          )
          )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(
          color: Colors.grey,
          width:2
          )),
         color: Color(0xFF1B5E20),
        ),
        padding: EdgeInsets.all(5),
        height: 280,
    );
  }

  void getSticker(){
    focusNode.unfocus();
    setState(() {
      DisplaySticker = !DisplaySticker;
    });
  }
  createListMessages(){
    return Flexible(
      child: chatId == "" 
      ? Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ) 
        : StreamBuilder(
          stream: Firestore.instance
          .collection("messages")
          .document(chatId)
          .collection(chatId)
          .orderBy("timestamp", descending: true)
          .limit(20)
          .snapshots(),

          builder: (context, snapshot){
            if(!snapshot.hasData){
             return Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ); 
            }
            else{
              listMessage = snapshot.data.documents;
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemBuilder: (context, index) => createItems(index, snapshot.data.documents[index]),
                itemCount: snapshot.data.documents.length,
                reverse: true,
                controller: listscrollcontroller,
                );
            }
          }, 
   
     )
     );
  }
 bool isLastMsgLeft(int index){
    if((index > 0 && listMessage !=null && listMessage[index-1]["idFrom"] == id) || index == 0){
      return true;
    }
    else{
      return false;
    }
  }

 bool isLastMsgRight(int index){
    if((index>0 && listMessage!=null && listMessage[index-1]["idFrom"]!=id) || index==0){
      return true;
    }
    else{
      return false;
    }
  }


Widget createItems(int index, DocumentSnapshot document){
//User Message
if(document ["idFrom"] == id){
return Row(
  children: <Widget>[
    //User Message 
  document["type"] == 0
  ? Container(
    child: Text(
      document["content"],
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500
      ),
    ),
    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
    width: 200,
    decoration: BoxDecoration(
      color: Colors.lightBlueAccent,
      borderRadius: BorderRadius.circular(8),
    ),
    margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
  )
  //Image Msg
  : document["type"] ==1   
  ? Container(
    child: FlatButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => FullPhoto(url: document["content"]))
        );
      }, 
    child: Material(
      child: CachedNetworkImage(
        placeholder: (context, url) => Container(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
          width: 200,
          height: 200,
          padding: EdgeInsets.all(70),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
        ),
        errorWidget: (context, url, error) =>   Material(
          child: Image.asset("assets/logo.png",
          width: 200,
          height: 200,
          fit: BoxFit.cover
          ),
          clipBehavior: Clip.hardEdge,
        ),
        imageUrl: document["content"],
         width: 200,
         height: 200,
         fit: BoxFit.cover
      ),
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    ),
    margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
  )
  //Sticker Msg
  : Container(
    child: Image.asset(
      "assets/${document['content']}.gif",
      width: 150,
      height: 150,
      fit: BoxFit.cover,
    ),
    margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10, right: 10),
  )
  ],
  mainAxisAlignment: MainAxisAlignment.end,
);
}
else{
  return Container(
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            isLastMsgLeft(index)
            ? Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                  ),
                  width: 35,
                  height: 35,
                ),
                imageUrl: receiverAvatar,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(18),
              ),
              clipBehavior: Clip.hardEdge,
              )
            : Container(
              width: 35,
            ),

    document["type"] == 0
  ? Container(
    child: Text(
      document["content"],
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500
      ),
    ),
    padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
    width: 200,
    decoration: BoxDecoration(
      color: Colors.lightGreen,
      borderRadius: BorderRadius.circular(8),
    ),
    margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10,left: 10),
  )
  
  
   //Image Msg
  : document["type"] ==1   
  ? Container(
    child: FlatButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => FullPhoto(url: document["content"]))
        );
      }, 
    child: Material(
      child: CachedNetworkImage(
        placeholder: (context, url) => Container(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
          width: 200,
          height: 200,
          padding: EdgeInsets.all(70),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(8.0))
          ),
        ),
        errorWidget: (context, url, error) =>   Material(
          child: Image.asset("assets/logo.png",
          width: 200,
          height: 200,
          fit: BoxFit.cover
          ),
          clipBehavior: Clip.hardEdge,
        ),
        imageUrl: document["content"],
         width: 200,
         height: 200,
         fit: BoxFit.cover
      ),
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    ),
    margin: EdgeInsets.only(left: 10),
  )

   //Sticker Msg
  : Container(
    child: Image.asset(
      "assets/${document['content']}.gif",
      width: 150,
      height: 150,
      fit: BoxFit.cover,
    ),
    margin: EdgeInsets.only(bottom: isLastMsgRight(index) ? 20 : 10, left: 10),
            )
            ]          
            ),
         

        isLastMsgLeft(index)
        ? Container(
          child: Text(
            DateFormat("dd MMMM, yyyy - hh:mm:aa")
            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(document["timestamp"]))),
            style: TextStyle(
          color: Colors.grey,
          fontSize: 15,
          fontStyle: FontStyle.italic
          )
        )
        ) : Container(),
         ],
         crossAxisAlignment: CrossAxisAlignment.start,
        ),
          margin: EdgeInsets.only(bottom: 10),
     );
}
}
createInputs(){
  return Container(
    child: Row(
      children: <Widget>[
      Material(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1),
          child: IconButton(
            icon: Icon(Icons.image),
            color: Colors.greenAccent,
            onPressed: (){
              getImage();
            }),
        ),
        color: Colors.black,
      ),
      Material(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1),
          child: IconButton(
            icon: Icon(Icons.sentiment_neutral),
            color: Colors.greenAccent,
            onPressed: (){
              getSticker();
            }),
        ),
        color: Colors.black,
      ),

     //TextField
      Flexible(child: Container(
        child: TextField(
          controller: textEditingController,
          decoration: InputDecoration.collapsed(
            hintText: "Send Message...",
            hintStyle: TextStyle(
              color: Colors.lightGreen
            )
            ),
            focusNode: focusNode,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          )
        ),
      )),

      //Send Button
      Material(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            icon: Icon(Icons.send), 
            color: Colors.greenAccent,
            onPressed: (){
                SendMessage(textEditingController.text, 0);
            }),
        ),
        color: Colors.black,
      ),
    ],
    ),
    width: double.infinity,
    height: 50,
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Colors.grey,
        width: 2
        ),
      )
    ),
  );
}
// ignore: non_constant_identifier_names
void SendMessage(String conetentMsf, int type){
//1 - TextMsg
//2 - Emoji
//3 - Image
if(conetentMsf.trim() != ""){
  textEditingController.clear();

var docRef = Firestore.instance.collection("messages").document(chatId)
.collection(chatId).document(DateTime.now().millisecondsSinceEpoch.toString());

Firestore.instance.runTransaction((transaction) async{
await transaction.set(docRef, {
  "idFrom": id,
  "idTo": receiverId,
  "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
  "content": conetentMsf,
  "type": type
},);
});
listscrollcontroller.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
}
else{
  Fluttertoast.showToast(msg: "Can't Send Empty Message");
}
}
Future getImage() async{
 // ignore: deprecated_member_use
 imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
 if(imageFile != null){
   isLoading = true;
 }
 uploadImageFile();
}

Future uploadImageFile() async{
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName);
  StorageUploadTask storageUploadTask = storageReference.putFile(imageFile);
  StorageTaskSnapshot storageTaskSnapshot = await storageUploadTask.onComplete;

  storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
    imageUrl = downloadUrl;
    setState(() {
      isLoading = false;
      SendMessage(imageUrl, 1);
    });
  }, onError: (error){
    setState(() {
      isLoading = false;
    });
    Fluttertoast.showToast(msg: "This is not an image");
  });
}
}