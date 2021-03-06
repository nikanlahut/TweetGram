import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deneme_app/models/user.dart';
import 'package:deneme_app/pages/HomePage.dart';
import 'package:deneme_app/widgets/ProgressWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  Post({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue){
      if (eachValue == true)
      {
        counter = counter + 1;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    likes: this.likes,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
    likeCount: getTotalNumberOfLikes(this.likes),
  );
}


class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState({
    this.postId,
    this.ownerId,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });



  @override
  Widget build(BuildContext context)
  {
    isLiked = (likes[currentOnlineUserId] == true);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }




createPostHead(){
  return FutureBuilder(
    future: usersReference.doc(ownerId).get(),
    builder: (context, dataSnapshot){
      if(!dataSnapshot.hasData){
        return circularProgress();
      }
      User user = User.fromDocument(dataSnapshot.data);
      bool isPostOwner = currentOnlineUserId == ownerId;

      return ListTile(
        leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.grey,),
        title: GestureDetector(
          onTap: ()=> print("show profile"),
          child: Text(
            user.username,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(location, style: TextStyle(color: Colors.white),),
        trailing: isPostOwner ? IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white,),
          onPressed: ()=> print("deleted"),
        ) : Text(""),
      );
    },
  );
}

  removeLike(){
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if(isNotPostOwner){
      activityFeedReference.doc(ownerId).collection("feedItems").doc(postId).get().then((doc){
        if(doc.exists)
        {
          doc.reference.delete();
        }
      });
    }
  }

  addLike()
  {
    bool isNotPostOwner = currentOnlineUserId != ownerId;

    if(isNotPostOwner)
    {
      activityFeedReference.doc(ownerId).collection("feedItems").doc(postId).set({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImg": currentUser.url,
      });
    }
  }

  controlUserLikePost(){
    bool _liked = likes[currentOnlineUserId] == true;

    if(_liked)
    {
      postsReference.doc(ownerId).collection("usersPosts").doc(postId).update({"likes.$currentOnlineUserId": false});

      removeLike();

      setState(() {
        likeCount = likeCount - 1;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    }
    else if(!_liked)
    {
      postsReference.doc(ownerId).collection("usersPosts").doc(postId).update({"likes.$currentOnlineUserId": true});

      addLike();

      setState(() {
        likeCount = likeCount + 1;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), (){
        setState(() {
          showHeart = false;
        });
      });
    }
  }

createPostPicture(){
  return GestureDetector(
    onDoubleTap: ()=> controlUserLikePost,
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Image.network(url),
        showHeart ? Icon(Icons.favorite, size: 140.0, color: Colors.pink,) : Text(""),
      ],
    ),
  );
}


createPostFooter(){
  return Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0),),
          GestureDetector(
            onTap: ()=> controlUserLikePost(),
            child: Icon(
              isLiked   ? Icons.favorite : Icons.favorite_border,
              size: 28.0,
              color: Colors.pinkAccent,
            ),
          ),
          Padding(padding: EdgeInsets.only(right: 20.0),),
          GestureDetector(
            onTap: ()=> print("show comments"),
            child: Icon(Icons.chat_bubble_outline, size: 28.0, color: Colors.white,),
          ),
        ],
      ),
      Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0),
            child: Text(
              "$likeCount likes",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0),
            child: Text("$username ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          ),
          Expanded(
            child: Text(description, style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    ],
  );
}
}