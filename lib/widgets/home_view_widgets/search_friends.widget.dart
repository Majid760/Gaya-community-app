import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/controller/homepage.controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:provider/provider.dart';

class SearchPeople extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    final controller = context.read<HomePageController>();

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        controller.allUsername.clear();
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? currentUser = firebaseAuth.currentUser;

    // final controller = context.read<HomePageController>();
    return StreamBuilder<QuerySnapshot>(
      stream: (query != "")
          ? FirebaseFirestore.instance
              .collection('users')
              .where('name', isEqualTo: query)
              .where('uid', isNotEqualTo: currentUser!.uid)
              .snapshots()
          : FirebaseFirestore.instance.collection("users").where('uid', isNotEqualTo: currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: snapshot.data?.docs.length ?? 1,
                itemBuilder: (context, index) {
                  DocumentSnapshot? data = snapshot.data!.docs[index];

                  return ListTile(
                      leading: data['profilePic'] == ''
                          ? const CircleAvatar(
                              backgroundColor: kBaseGrey,
                            )
                          : CircleAvatar(
                              radius: 20,
                              // backgroundImage: CachedNetworkImageProvider(
                              //   data['profilePic'],
                              // ),
                              child: CachedNetworkImage(
                                memCacheHeight: 50,
                                memCacheWidth: 50,
                                imageUrl: data['profilePic'],
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                  child: const Center(
                                      child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  )),
                                ),
                                placeholder: (context, url) => Image.asset(
                                  Assets.assets.images.communityLogo,
                                ),
                              ),
                            ),
                      title: Text(
                        data['name'],
                      ),
                      // subtitle: Text(
                      //   data['uid'],
                      // ),
                      onTap: () {
                        Future.delayed(const Duration(milliseconds: 300));
                      });
                },
              );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? currentUser = firebaseAuth.currentUser;
    return StreamBuilder<QuerySnapshot>(
      stream: (query != "")
          ? currentUser == null
              ? FirebaseFirestore.instance.collection('users').where('name', isEqualTo: query).snapshots()
              : FirebaseFirestore.instance.collection('users').where('name', isEqualTo: query).snapshots()
          : currentUser == null
              ? FirebaseFirestore.instance.collection("users").snapshots()
              : FirebaseFirestore.instance.collection("users").where('uid', isNotEqualTo: currentUser.uid).snapshots(),
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot? data = snapshot.data!.docs[index];
                  return ListTile(
                      leading: data['profilePic'] == ''
                          ? const CircleAvatar(
                              backgroundColor: kBaseGrey,
                            )
                          : CircleAvatar(
                              radius: 20,
                              // backgroundImage: CachedNetworkImageProvider(
                              //   data['profilePic'].toString(),
                              // ),
                              child: CachedNetworkImage(
                                memCacheHeight: 50,
                                memCacheWidth: 50,
                                imageUrl: data['profilePic'] ?? '',
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                  child: const Center(
                                      child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  )),
                                ),
                                placeholder: (context, url) => Image.asset(
                                  Assets.assets.images.userDefault,
                                ),
                              ),
                            ),
                      title: Text(
                        data['name'].toString(),
                      ),
                      // subtitle: Text(
                      //   data['uid'],
                      // ),
                      onTap: () {
                        query = data['name'];
                        final UserModel? user;
                        try {
                          user = UserModel.fromMap(data.data() as Map<String, dynamic>, userId: data.id);
                          Routes.viewProfile(uid: user.uId, model: user);
                        } catch (_) {}
                      });
                });
      },
    );
  }
}

/**rules_version = '2';
    service cloud.firestore {
    match /databases/{database}/documents {
    match /{document=**} {
    allow read, write: if
    request.time < timestamp.date(2022, 9, 3);
    }
    }
    } */
