import 'package:gaya/utils/enum.dart';

abstract class PostType {
  PostCreationFrom typeOfPost;

  PostType(this.typeOfPost);
}

class PostReplyDataType extends PostType {
  String? postType;
  String? profilePic;
  String? commentUserName;
  String? commentId;
  List<Map<String, dynamic>>? mentionedUsersList;
  String? postId;
  String? commentTime;
  String? content;
  DateTime? commentTimeFromNow;
  bool? isAnonymousPost;
  String? postAuthorId;
  String? commentAuthorId;

  PostReplyDataType({
    required this.postType,
    required this.profilePic,
    required this.commentUserName,
    required this.commentId,
    required this.mentionedUsersList,
    required this.postId,
    required this.commentTime,
    required this.content,
    required this.commentTimeFromNow,
    required this.isAnonymousPost,
    required this.postAuthorId,
    required this.commentAuthorId,
  }) : super(PostCreationFrom.postReply);

  PostReplyDataType.fromJson(Map<String, dynamic> map) : super(PostCreationFrom.postReply) {
    postType = map['postType']?.toString() ?? "";
    profilePic = map['profilePic']?.toString() ?? "";
    commentUserName = map['commentUserName']?.toString() ?? "";
    commentId = map['commentId']?.toString() ?? "";
    isAnonymousPost = map['isAnonymousPost'] ?? false;
    mentionedUsersList = (map['comment'] == null)
        ? null
        : (map['comment'])?.map<Map<String, dynamic>>((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              return Map<String, dynamic>.from(item);
            }
          }).toList();
    postId = map['postId']?.toString() ?? "";
    commentTime = map['commentTime']?.toString() ?? "";
    commentTimeFromNow = map['commentTimeFromNow']?.toDate();
    content = map['content']?.toString() ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      'postType': postType,
      'profilePic': profilePic,
      'commentUserName': commentUserName,
      'commentId': commentId,
      'comment': mentionedUsersList,
      'postId': postId,
      'commentTime': commentTime,
      'content': content,
      'commentTimeFromNow': commentTimeFromNow,
    };
  }
}

class PostWithVibes extends PostType {
  String? postType;
  String? name;
  String? emoji;

  PostWithVibes(this.postType, this.name, this.emoji) : super(PostCreationFrom.vibe);

  PostWithVibes.fromJson(Map<String, dynamic> map) : super(PostCreationFrom.vibe) {
    postType = map['postType']?.toString() ?? "";
    name = map['name']?.toString() ?? "";
    emoji = map['emoji']?.toString() ?? "";
  }

  Map<String, dynamic> toJson() {
    return {'postType': postType, 'name': name, 'emoji': emoji};
  }
}

class PostWithPoll extends PostType {
  PostWithPoll({
    this.postType,
    required this.id,
    required this.question,
    required this.options,
  }) : super(PostCreationFrom.poll);
  String? postType;
  String? id;
  String? question;
  List<Options>? options;

  PostWithPoll.fromJson(Map<String, dynamic> json) : super(PostCreationFrom.poll) {
    postType = json['postType']?.toString() ?? "";
    id = json['id'];
    question = json['question'];
    options = List.from(json['options']).map((e) => Options.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['postType'] = postType;
    _data['id'] = id;
    _data['question'] = question;
    _data['options'] = options?.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Options {
  Options({
    required this.id,
    required this.title,
    required this.counts,
  });
  late int id;
  late String title;
  late int counts;

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    counts = json['counts'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['title'] = title;
    _data['counts'] = counts;
    return _data;
  }
}
