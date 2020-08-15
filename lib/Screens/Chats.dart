import 'package:cached_network_image/cached_network_image.dart';
import 'package:didicodes/Screens/ChatScreen.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  final String receiverId;
  final String receiverImage;
  final String receiverName;

Chat({Key key, 
@required this.receiverId, 
@required this.receiverImage, 
@required this.receiverName
});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF1B5E20),
        centerTitle: true,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              
          CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: CachedNetworkImageProvider(receiverImage),
          ),
          SizedBox(width: 10),
            Text(
              receiverName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            )
          ]
        ),
        actions: <Widget>[
          Container(
            child: IconButton(
              icon: Icon(Icons.videocam),
              color: Colors.white,
              iconSize: 25,
              onPressed: (){},
              )
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: ChatScreen(
          receiverAvatar: receiverName,
          receiverId: receiverId
        ),
    );
  }
}


