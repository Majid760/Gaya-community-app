// import 'package:flutter/material.dart';
// import 'package:gaya/widgets/messaging.widgets/getmessages.list.widget.dart';
//
// import '../../view/comments/models/message.model.dart';
// import '../../utils/const.dart';
//
// class GetMessages extends StatelessWidget {
//   const GetMessages({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           SizedBox(
//             height: distance_15,
//           ),
//           ListView.separated(
//               separatorBuilder: (context, index) => Column(
//                     children: [
//                       SizedBox(
//                         height: distance_15,
//                       ),
//                       Divider(
//                         color: kBaseGrey,
//                       )
//                     ],
//                   ),
//               primary: false,
//               shrinkWrap: true,
//               itemCount: messagesDetails.length,
//               itemBuilder: (context, index) {
//                 return GetMessageList(
//                   isRead: messagesDetails[index].isRead,
//                   message: messagesDetails[index].message,
//                   name: messagesDetails[index].name,
//                   profileImage: messagesDetails[index].image,
//                   time: messagesDetails[index].time, ontap: () {  },
//                 );
//               }),
//         ],
//       ),
//     );
//   }
// }
