import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';

final Services services = Services();

Future<void> convertAllPostsToNewSchema() async {
  // fewtch posts
  final allPostsSnapshot = await FirebaseFirestore.instance.collection('communityposts').get();
  final allPosts = allPostsSnapshot.docs;

  try {
    allPosts.forEach((singlePostSnap) async {
      final postData = singlePostSnap.data() as Map<String, dynamic>;
      final communityId = postData["communityId"];
      //load who posted it
      final userId = postData["memberId"];
      loadAndConvert(postRef: singlePostSnap.reference, communityId: communityId, postedByUid: userId);
    });
  } catch (e, s) {
    print(s);
  }
}

Future<void> convertSinglePost() async {
  final singlePostSnap = await FirebaseFirestore.instance.collection('communityposts').doc("d0e9bad0-837e-11ed-a57a-39cf87756eb0").get();
  final postData = singlePostSnap.data() as Map<String, dynamic>;
  final communityId = postData["communityId"];
  //load who posted it
  final userId = postData["memberId"];
  try {
    loadAndConvert(postRef: singlePostSnap.reference, communityId: communityId, postedByUid: userId);
  } catch (e) {
    print(e);
  }
}

Future<void> loadAndConvert({required DocumentReference postRef, required String communityId, required String postedByUid}) async {
  final likes = await postRef.collection('likes').get();
  final flowers = await postRef.collection('flowers').get();
  final comments = await postRef.collection('comments').get();
  final Community? community = await addCommunityAsPostBy(communityId: communityId);
  final UserModel? postedBy = await services.getUserById(postedByUid);

  final likesCount = likes.docs.length;
  final flowersCount = flowers.docs.length;
  final commentsCount = comments.docs.length;

  await postRef.set({
    'likedBy': List.generate(likesCount, (index) => likes.docs[index].data()['userUid']),
    'flowersBy': List.generate(flowersCount, (index) => flowers.docs[index].data()['userUid']),
    'totalCommentsCount': commentsCount,
    'community': community?.toMap(),
    'postedBy': postedBy?.toPublicJson(),
  }, SetOptions(merge: true));
}

Future<Community?> addCommunityAsPostBy({required String communityId}) async {

  try {
    // add community as post by
    final communityRef = FirebaseFirestore.instance.collection('communities').doc(communityId);
    final communitySnap = await communityRef.get();
    final communityData = communitySnap.data() as Map<String, dynamic>;

    Community communityModel = Community.fromMap(communityData);
    return communityModel;
  } catch (e) {
    print("error at community $e");
  }
}
