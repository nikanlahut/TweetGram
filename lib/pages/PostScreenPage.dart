import 'package:deneme_app/pages/HomePage.dart';
import 'package:deneme_app/widgets/HeaderWidget.dart';
import 'package:deneme_app/widgets/PostWidget.dart';
import 'package:deneme_app/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget
{
  final String postId;
  final String userId;


  PostScreenPage({
    this.userId,
    this.postId
  });


  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder(
      future: postsReference.doc(userId).collection("usersPosts").doc(postId).get(),
      builder: (context, dataSnapshot)
      {
        if(!dataSnapshot.hasData)
        {
          return circularProgress();
        }

        Post post = Post.fromDocument(dataSnapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, strTitle: post.description),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}