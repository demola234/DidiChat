import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didicodes/Widgets/ProgressIndicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';


class Settings extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        backgroundColor: Color(0xFF1B5E20),
        title: Text("Settings",
        style: TextStyle(
          color: Colors.white,
          fontWeight:  FontWeight.bold
        )
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SettingsScreen(),
    );
  }
}


class SettingsScreen extends StatefulWidget {
  @override
  State createState() => SettingsScreenState();
}



class SettingsScreenState extends State<SettingsScreen> {

TextEditingController nicknameTextEditingController = TextEditingController();
TextEditingController bioTextEditingController = TextEditingController();

SharedPreferences preferences;
String id = "";
String nickname = "";
String bio = "";
String photoUrl = "";
File imageFileAvater;
bool isLoading = false;
final FocusNode nickNameFocusNode = FocusNode();
final FocusNode bioFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();

    readDataFromLocal();
  }

   void readDataFromLocal() async{
     preferences = await SharedPreferences.getInstance();
     id = preferences.getString("id");
     nickname = preferences.getString("nickname"); 
     bio = preferences.getString("bio"); 
     photoUrl = preferences.getString("photoUrl");

     nicknameTextEditingController = TextEditingController(text: nickname);
     bioTextEditingController = TextEditingController(text: bio);

     setState(() {
       
     });
    }

    Future getImage()async{
      
      // ignore: deprecated_member_use
      File newImageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

      if(newImageFile != null){
        setState(() {
          this.imageFileAvater = newImageFile;
          isLoading = true;
        });
      }
      uploadImageToFirestoreAndStorage();
    }

      Future uploadImageToFirestoreAndStorage() async{
        String mFileName = id;
        StorageReference storageReference = FirebaseStorage.instance.ref().child(mFileName);
        StorageUploadTask storageUploadTask = storageReference.putFile(imageFileAvater);
        StorageTaskSnapshot storageTaskSnapshot;
        storageUploadTask.onComplete.then((value){
          if(value.error == null){
            storageTaskSnapshot = value;
            storageTaskSnapshot.ref.getDownloadURL().then((newImageDownload){
              photoUrl = newImageDownload;

              Firestore.instance.collection("users").document(id)
              .updateData({
                "photoUrl" : photoUrl,
                "bio" : bio,
                "nickname" : nickname,
                 }).then((data) async{
                   await preferences.setString("photoUrl", photoUrl);
                   setState(() {
                     isLoading = false;
                   });
                   Fluttertoast.showToast(msg: "Update Complete");
                 });

            },onError: (errorMsg){
              setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: "Error Occured Getting Download Url");
        });

          }
        }, onError: (errorMsg){
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: errorMsg.toString());
        });
      }


  void updataData(){
    nickNameFocusNode.unfocus();
    bioFocusNode.unfocus();

    setState(() {
      isLoading = false;
    });
    Firestore.instance.collection("users").document(id)
              .updateData({
                "photoUrl" : photoUrl,
                "bio" : bio,
                "nickname" : nickname,
                 }).then((data) async{
                  await preferences.setString("photoUrl", photoUrl);
                  await preferences.setString("bio", bio);
                  await preferences.setString("nickname", nickname);


                   setState(() {
                     isLoading = false;
                   });
                   Fluttertoast.showToast(msg: "Update Complete");
                 });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              //Profile Image
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                        (imageFileAvater == null) 
                        ? (photoUrl != "")
                        ? Material(
                          //Display Already Existing
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.lightGreenAccent),
                              ),
                              width: 150,
                              height: 150,
                              padding: EdgeInsets.all(20),
                            ),
                            imageUrl: photoUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        borderRadius: BorderRadius.all(Radius.circular(125)),
                        clipBehavior: Clip.hardEdge,
                        ) 
                        : Icon(Icons.account_circle, size: 60,
                        color: Colors.white38,)
                        : Material(
                        //Display new Image  
                        child: Image.file(
                          imageFileAvater,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(125)),
                        clipBehavior: Clip.hardEdge,
                        ),
                        IconButton(
                          icon: Icon(Icons.camera_alt,
                          size: 70,
                          color: Colors.white.withOpacity(0.3),
                          ), 
                          onPressed: getImage,
                          padding: EdgeInsets.all(0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.grey,
                          iconSize: 200,
                          ),
                    ],
                  )
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20),
              ),
                //User Information
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                              color: Colors.white.withOpacity(0.4),
                              offset: Offset(0,3),
                              spreadRadius: 1,
                              blurRadius: 5
                            )]
                ),
                child: Column(
                  children: <Widget>[
                          Padding(padding: EdgeInsets.all(1),
                          child: isLoading ? circularProgress() : Container(),),
                        //Username
                        SizedBox(width: 20),
                        Container(
                        child: Text(
                          "Profile Name: ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                           margin: EdgeInsets.only(left: 10, bottom: 5,top: 10)
                        ),
                        SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                              color: Colors.white,
                              offset: Offset(0,3),
                              spreadRadius: 1,
                              blurRadius: 5
                            )]
                          ),
                        child: Theme(
                          data: Theme.of(context).copyWith(primaryColor: Colors.green), 
                          child: TextField(
                            style: TextStyle(
                              color: Colors.black,
                              
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "UserName",
                              contentPadding: EdgeInsets.all(5),
                              hintStyle: TextStyle(color: Colors.black
                            ),
                            
                          ),
                          controller: nicknameTextEditingController,
                          onChanged: (value){
                            nickname = value;
                          },
                          focusNode: nickNameFocusNode,
                          ),
                        ),
                        margin: EdgeInsets.only(left: 30, right: 30),
                        ),
                        SizedBox(height: 30),
                        //User Bio
                      
                        Container(
                            child: Text(
                         "  Profile Bio: ",
                         textAlign: TextAlign.center,
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           color: Colors.white 
                         ),
                            ),
                          ),
                          SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                              color: Colors.white,
                              offset: Offset(0, 3),
                              spreadRadius: 1,
                              blurRadius: 5
                            )]
                          ),
                          child: Theme(
                        data: Theme.of(context).copyWith(primaryColor: Colors.green), 
                        child: TextField(
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Bio",
                            contentPadding: EdgeInsets.all(5),
                            hintStyle: TextStyle(
                            color: Colors.grey
                          ),
                        ),
                        controller: bioTextEditingController,
                        onChanged: (value){
                        bio = value;
                        },
                        focusNode: bioFocusNode,
                        ),
                        ),
                        margin: EdgeInsets.only(left: 30, right: 30),
                        ),
                        SizedBox(height: 20)
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        
                        ),
                        
              ),
                      //Updata And LogOut Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: FlatButton(
                          onPressed: (){
                            updataData();
                          },
                          child: Text("Update",
                          style: TextStyle(
                            fontSize: 16
                          ),
                          ),
                          color: Color(0xFF1B5E20),
                          highlightColor: Colors.white,
                          splashColor: Colors.transparent,
                          textColor: Colors.white,
                          padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          shape: StadiumBorder(),
                        ),
                        margin: EdgeInsets.only(top: 50, bottom:1),
                      ),
                      Padding(padding: EdgeInsets.only(left: 50, right: 50),
                      child: RaisedButton(
                        onPressed: (){
                          logoutUser();
                        },
                        shape: StadiumBorder(),
                        color: Colors.red,
                        child: Text("Sign Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14
                        ),
                        ),
                      ),
                      )
            ]
        ),
        padding: EdgeInsets.only(left: 15, right: 15),
        )],
    );
  }

final GoogleSignIn googleSignIn = GoogleSignIn();
 Future <Null> logoutUser() async{
 await FirebaseAuth.instance.signOut();
 await googleSignIn.disconnect();
 await googleSignIn.signOut();

 setState(() {
   isLoading= false;
 });
 
 Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), ( Route<dynamic> route) => false);
}
}
