import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gaya/services/services.dart';

import '../app.dart';
import '../model/communities.memebers.model.dart';
import '../model/create.post.model.dart';
import '../model/user.model.dart';

class PostsScript {
  final services = Services.to;

  Future<void> postInCommunity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    const community = "1163d610-8f4e-11ed-af30-83d11c1c3a22";
    final communityModel = (await services.getCommunityDetailsModel(community))!;
    final appUser = (await services.getUserById(user.uid))!;
    randomPostsDescription.forEach((desc) async {
      Post postModel = Post(
          postedBy: appUser,
          community: communityModel,
          memberId: user.uid,
          postTopicList: [],
          multipleImages: [],
          postDescription: desc,
          postCreatedOn: DateTime.now(),
          communityId: communityModel.communityId,
          approve: false,
          postid: uuid.v1(),
          isDeleted: false,
          isPostedAnonymously: false,
          video: '',
          pdfFiles: []);
      await services.setPostDetails(postModel.toMap(), postModel.postid.toString());
    });
  }

  List<String> randomPostsDescription = [
    "I just learned how to make a new recipe and I can't wait to try it out",
    "I'm so happy to be spending time with my loved ones today",
    "I'm feeling inspired and motivated to create something new",
    "I'm grateful for all the good things in my life",
    "I'm excited to see what the next chapter of my life holds",
    "I'm ready to take on the world!",
    "I'm feeling so grateful for all of the people in my life",
    "I'm so excited to be starting a new chapter in my life",
    "I'm feeling so grateful for all of the opportunities that have come my way",
    "I just went on a vacation and I had the time of my life.",
    "I just finished reading a great book and I can't wait to start the next one.",
    "I just watched a great movie and I can't wait to see it again.",
    "I just listened to a great album and I can't stop singing along.",
    "I just ate a delicious meal and I'm so full and satisfied.",
    "I just went for a walk in the park and I felt so relaxed and refreshed.",
    "I just spent time with my loved ones and I felt so happy and loved.",
    "I just helped someone in need and I felt so good about myself.",
    "I just made a difference in the world and I felt so proud of myself.",
    "I just learned something new and I felt so excited to share it with others.",
    "I just created something new and I felt so proud of myself.",
    "I just accomplished a goal and I felt so proud of myself.",
    "I just finished a project and I felt so proud of myself.",
    "I just learned how to make a new recipe and I can't wait to try it out",
    "I'm so happy to be spending time with my loved ones today",
    "I'm feeling inspired and motivated to create something new",
    "I'm grateful for all the good things in my life",
    "I'm excited to see what the next chapter of my life holds",
    "I'm ready to take on the world!",
    "I'm feeling so grateful for all of the people in my life",
    "I'm so excited to be starting a new chapter in my life",
    "I'm feeling so grateful for all of the opportunities that have come my way",
    "I just went on a vacation and I had the time of my life.",
    "I just finished reading a great book and I can't wait to start the next one.",
    "I just watched a great movie and I can't wait to see it again.",
    "I just listened to a great album and I can't stop singing along.",
    "I just ate a delicious meal and I'm so full and satisfied.",
    "I just went for a walk in the park and I felt so relaxed and refreshed.",
    "I just spent time with my loved ones and I felt so happy and loved.",
    "I just helped someone in need and I felt so good about myself.",
    "I just made a difference in the world and I felt so proud of myself.",
    "I just learned something new and I felt so excited to share it with others.",
    "I just created something new and I felt so proud of myself.",
  ];
}

class ApplyToCommunity {
  final services = Services.to;

  void applyToCommunity(String communityId) async {
    final rawUsers = (await _getAllUser());
    final users = rawUsers.map((e) => UserModel.fromMap(e.data(), userId: e.id)).toList();
    users.forEach((element) {
      if (element.uId != null) {
        _join(element.uId ?? "", communityId);
      }
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getAllUser() async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .limit(50)
        .get();
    return users.docs;
  }

  Future<void> _join(String userId, communityId) async {
    print("joining for user: $userId");
    CommunityMembership addMember = CommunityMembership(isAdmin: false, isMember: false, userUid: userId, createdOn: DateTime.now());
    services.requestToCommunity(id: communityId);
    bool isAlreadyMember = (await FirebaseFirestore.instance
            .collection('communities')
            .doc(communityId)
            .collection('communityMembers')
            .doc(addMember.userUid)
            .get())
        .exists;
    if (!isAlreadyMember) {
      return await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('communityMembers')
          .doc(addMember.userUid)
          .set(addMember.toMap());
    }
  }
}
