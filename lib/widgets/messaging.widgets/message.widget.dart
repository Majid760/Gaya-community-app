
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../utils/const.dart';
import '../../utils/textstyles.dart';
class MessageWidget extends StatelessWidget {
  // final bool isMe, isContinue;

  final String messaging;
  const MessageWidget({
    Key? key,
    // required this.isMe,
    required this.messaging,
    // required this.isContinue,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    User ? user  = _firebaseAuth.currentUser;
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: distance_10, horizontal: distance_20),
      child:
      
       user!.uid.isNotEmpty  
          ? Align(
              alignment: Alignment.bottomRight,
              child: IntrinsicWidth(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                      horizontal: distance_20, vertical: distance_10),
                  decoration: const BoxDecoration(
                      color: kprimaryColor,
                      borderRadius: 
                      
                      // isContinue == false
                      //     ? BorderRadius.only(
                      //         topLeft: Radius.circular(20),
                      //         topRight: Radius.circular(20),
                      //         bottomLeft: Radius.circular(20),
                      //         bottomRight: Radius.circular(4))
                      //     :
                          
                           BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20))),
                  child: Text(
                    messaging,
                    style: CustomTypography.body2Style,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: distance_10, horizontal: distance_20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      // isContinue == true
                      //     ? CircleAvatar(
                      //         radius: 16,
                      //         backgroundImage:
                      //             CachedNetworkImageProvider(profileImage),
                      //       )
                      //     : 
                          
                      //     CircleAvatar(
                      //         radius: 16,
                      //         backgroundColor: kTransparentColor,
                      //       ),
                      const SizedBox(
                        width: distance_10,
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: distance_20, vertical: distance_10),
                        decoration: const BoxDecoration(
                            color: kBaseGrey,
                            borderRadius: 
                            // isContinue == false
                            //     ? BorderRadius.only(
                            //         topLeft: Radius.circular(20),
                            //         topRight: Radius.circular(20),
                            //         bottomLeft: Radius.circular(4),
                            //         bottomRight: Radius.circular(20))
                                // : 
                                BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16))),
                        child: Text(messaging),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
