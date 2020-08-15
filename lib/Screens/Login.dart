import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didicodes/Widgets/ProgressIndicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreenState.dart';


class Login extends StatefulWidget {

  Login({Key key}) : super(key : key);

  @override
  _LoginState createState() => _LoginState();
}
 
class _LoginState extends State<Login> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences preferences;

  bool isLoggedIn = false;
  bool isLoading = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();

    isSignedIn();
  }

  void isSignedIn() async{
    this.setState(() {
      isLoggedIn = true;
    });

    preferences = await SharedPreferences.getInstance();
    isLoggedIn = await googleSignIn.isSignedIn();

    if(isLoading){
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: preferences.getString("id"))));

    }
    this.setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.jpeg"
            ),
            fit: BoxFit.cover,
          ),
        ),

        child: Stack(
          children: <Widget>[
            Center(
              child: Container(
                margin: const EdgeInsets.all(48.0),
                padding: const EdgeInsets.symmetric(horizontal: 30.0,vertical: 40.0),
                decoration: BoxDecoration(
                  color : Colors.white70.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Image.asset("assets/logoo.png",
                        fit: BoxFit.contain,
                      ),
                      
                      GestureDetector(
                          onTap: (){
                            controlSignIn();
                        },
                       child: Container(
                         padding: EdgeInsets.all(20),
                         margin: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.green,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.google,
                                size: 30,
                                color: Colors.lightBlueAccent,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Continue with Google", 
                                  textAlign: TextAlign.center, 
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0
                                )
                                )
                              ],
                            ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(10),
                      child: isLoading 
                      ? circularProgress() 
                      : Container(),
                      )
                    ],
                  ),
                  )
              )
            )
          ],
        ),
      ),
    );
  }
 Future<Null> controlSignIn() async{

   preferences = await SharedPreferences.getInstance();
   this.setState(() {
     isLoading = true;
   });

   GoogleSignInAccount googleUser = await googleSignIn.signIn();
   GoogleSignInAuthentication googleAuthentication = await googleUser.authentication;

   final AuthCredential credential = GoogleAuthProvider.getCredential(
     idToken: googleAuthentication.idToken, 
     accessToken: googleAuthentication.accessToken);

    FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential))
    .user;

    //SIGNIN SUCCESSFUL
    if(firebaseUser != null){
      //Check if already Signed Up
      final QuerySnapshot resultQuery = await Firestore.instance
      .collection("users").where("id", isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.documents;

      //Save Data To FireStore
      if(documentSnapshots.length == 0){
        Firestore.instance.collection("users").document(firebaseUser.uid).setData({
          "nickname" : firebaseUser.displayName,
          "photoUrl" : firebaseUser.photoUrl,
          "id" : firebaseUser.uid,
          "bio" : "Currently Available!",
          "creatdAt" : DateTime.now().millisecondsSinceEpoch.toString(),
          "chattingWith" : null
        });
      //Writing Data To Local
      currentUser = firebaseUser;
      await preferences.setString("id", currentUser.uid);
      await preferences.setString("nickname", currentUser.displayName);
      await preferences.setString("photoUrl", currentUser.photoUrl);
      }

      else{
     //Writing Data To Local
      currentUser = firebaseUser;
      await preferences.setString("id", documentSnapshots[0]["id"]);
      await preferences.setString("nickname", documentSnapshots[0]["nickname"]);
      await preferences.setString("photoUrl", documentSnapshots[0]["photoUrl"]);
      await preferences.setString("bio", documentSnapshots[0]["bio"]);
      }

      Fluttertoast.showToast(msg: "SignIn Successful");
      this.setState(() {
        isLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: firebaseUser.uid),));

    }
    //SIGNIN FAILED
    else{
      Fluttertoast.showToast(msg: "Try Again, SignIn Failed");
      this.setState(() {
        isLoading = false;
      });
    }
 }
}