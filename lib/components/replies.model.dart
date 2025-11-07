import 'package:gaya/utils/const.dart';

class CommentModel {
  final String profilePicture;
  bool isLiked, isFlower;
  final int id;
  final String name;
  final String content;
  final String time;
  final List<Data> replies;

  CommentModel(
      {required this.profilePicture,
      required this.replies,
      required this.isFlower,
      required this.isLiked,
      required this.id,
      required this.name,
      required this.content,
      required this.time});
}

List<CommentModel> commentList = [
  CommentModel(
      profilePicture: profileImage1,
      id: 1,
      name: 'Noa Hilizenart',
      content: 'This is my first post',
      time: '17 hr',
      isFlower: false,
      isLiked: false,
      replies: dataList),
  // CommentModel(
  //     profilePicture: profileImage2,
  //     id: 2,
  //     name: 'Jhon Doe',
  //     content: 'Good Recipe , i tried it',
  //     time: '15 hr',
  //     isFlower: false,
  //     isLiked: false,
  //     replies: []),
  // CommentModel(
  //     profilePicture: profileImage4,
  //     id: 3,
  //     name: 'Awais',
  //     content: 'Welcome to community',
  //     time: '1 hr',
  //     isFlower: false,
  //     isLiked: false,
  //     replies: []),
];

class Reply {
  final List<Data> data;
  Reply({
    required this.data,
  });
}

class Data {
  final String profilePicture;
  final String name;
  final String content;
  final String time;

  Data({
    required this.name,
    required this.content,
    required this.profilePicture,
    required this.time,
  });
}

List<Data> dataList = [
  Data(
      name: 'Moid',
      content: "hello this is my comment",
      profilePicture: profileImage1,
      time: '2 hr')
];
