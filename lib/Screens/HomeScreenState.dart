import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didicodes/Models/user.dart';
import 'package:didicodes/Screens/UserResult.dart';
import 'package:didicodes/Widgets/ProgressIndicator.dart';
import 'package:flutter/material.dart';
import 'Settings.dart';


class HomeScreen extends StatefulWidget {
  final String currentUserId;
  
  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState(currentUserId: currentUserId);
}


class _HomeScreenState extends State<HomeScreen> {
_HomeScreenState({Key key, @required this.currentUserId});
TextEditingController searchTextEditingController = TextEditingController();
Future<QuerySnapshot> futureSearchResults;
final String currentUserId;

  homepageappbar(){
    return AppBar(
      backgroundColor: Color(0xFF1B5E20),
      automaticallyImplyLeading: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings,
          size: 25,
          color: Colors.white,
          ), 
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
          })
      ],
      title: Container(
        margin: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        height: 45,
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.all(Radius.circular(30)),
          child: TextFormField(
            controller: searchTextEditingController,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF1B5E20),
            ),
            cursorColor: Colors.lightGreenAccent,
            decoration: InputDecoration(
              prefixIcon: 
              Icon(Icons.person_outline,color:Colors.green),
              suffixIcon: Material(
                elevation: 2,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: IconButton(
                  onPressed: (){
                    emptyTextField();
                  },
                  icon: Icon(
                    Icons.clear,
                  color: Colors.greenAccent,
                  ),
                  ),

              ),
              hintText: "Search Users",
              border:InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20, vertical: 11
              )
            ),
            onFieldSubmitted: controlSearch,
          ),
        ),
      ),
    );
  }
    controlSearch(String username){
      Future<QuerySnapshot> allFoundUsers = Firestore.instance.collection("users")
      .where("nickname", isGreaterThanOrEqualTo: username).getDocuments();

      setState(() {
        futureSearchResults = allFoundUsers;
      });
    }

    emptyTextField(){
   searchTextEditingController.clear();   
    }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: homepageappbar(),
      body: futureSearchResults == null ? displayNoResult() : displayUserFound(),
    ); 
  }

displayUserFound(){
 return FutureBuilder(
   future: futureSearchResults,
   builder: (context, dataSnapshot){
     if(!dataSnapshot.hasData){
       return circularProgress();
     }
     List<UserResult> searchUserResult = [];
     dataSnapshot.data.documents.forEach((document){
       User eachUser = User.fromDocument(document);
       UserResult userResult = UserResult(eachUser);
       if(currentUserId != document["id"]){
         searchUserResult.add(userResult);
       }
     });
     return ListView(
       children: searchUserResult
     );
   });
}

displayNoResult(){
  // ignore: unused_local_variable
  final Orientation orientation = MediaQuery.of(context).orientation;
  return Container(
    child: Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Icon(Icons.person_add,
          color: Colors.white,
          size: 200,
          ),
          Text("Search Users",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 50,
          ),
          )
        ],
      ),
    )
  );
}
}