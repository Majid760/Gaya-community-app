import 'package:flutter/foundation.dart';
import 'package:gaya/utils/extension.dart';
import '../../../model/create.post.model.dart';
import '../../../utils/logger.dart';

class CustomIsolatePost {
  static Future<List<Post>> sortPostInThread(List<Post> posts) async {
    try {
      return compute(_sortPosts, posts);
    } catch (_) {
      MyLoggerServices.to.print(_);
    }
    return posts;
  }


//sort and distinct the posts
  static List<Post> _sortPosts(List<Post> posts) {
    List<Post> _posts = posts;

    _posts.distinctBy((post) => post.postid ?? "");

    return posts;
  }

}