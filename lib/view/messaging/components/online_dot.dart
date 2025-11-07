import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PresenceIndicatorWidget extends StatelessWidget {
  final String uid;

  const PresenceIndicatorWidget({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  const SizedBox.shrink(); /*: StreamBuilder(
        stream: OnlineStatusServices().getUserActiveStatusStream(uid: uid),
        builder: (context, snapshot) {
          try {
            var val = snapshot.data;
            if (val is DatabaseEvent) {
              Map<String, dynamic> snapBody = val.snapshot.value as Map<String, dynamic>;
              UserStatusPresence userStatusPresence = UserStatusPresence.fromMap(snapBody);
              if (userStatusPresence.isOnline == true) {
                return Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.green),
                    const SizedBox(width: distance_5),
                    Text('Online', style: CustomTypography.bodyStyle.copyWith(fontSize: 10, fontStyle: FontStyle.italic, color: kSecondaryColor)),
                  ],
                );
              } else {
                return Text("Last seen ${Jiffy(userStatusPresence.lastSeen.toDate()).fromNow()}", style: const TextStyle(fontSize: 12));
              }
            } else {
              return const SizedBox.shrink();
            }
          } catch (_) {
            return const SizedBox.shrink();
          }
        });*/
  }
}

class UserStatusPresence {
  final Timestamp lastSeen;
  final bool isOnline;

  UserStatusPresence({required this.lastSeen, required this.isOnline});

  factory UserStatusPresence.fromMap(Map<String, dynamic> map) {
    return UserStatusPresence(
      lastSeen: map['last_seen'].toDate(),
      isOnline: map['presence'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'last_seen': lastSeen,
      'presence': isOnline,
    };
  }

  @override
  String toString() {
    return 'UserStatusPresence(lastSeen: $lastSeen, isOnline: $isOnline)';
  }
}
