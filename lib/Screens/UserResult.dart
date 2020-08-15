import 'package:cached_network_image/cached_network_image.dart';
import 'package:didicodes/Models/user.dart';
import 'package:flutter/material.dart';
import 'Chats.dart';


class UserResult extends StatelessWidget{

  final User eachUser;

  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
           color:  Colors.white38,
        ),
       
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: (){
                ChatPageSender(context);
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(eachUser.photoUrl),
                ),
                title: Text(
                  eachUser.nickname,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  )
                ),
                 subtitle: Text(
                    "Joined! ",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  // fontStyle: FontStyle.italic
                )
                ),
              )
            )
        ],)
      ),
    );
  }

  // ignore: non_constant_identifier_names
  ChatPageSender(BuildContext context){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => Chat(
      receiverId: eachUser.id, 
      receiverImage: eachUser.photoUrl, 
      receiverName: eachUser.nickname
      )));
  }
}