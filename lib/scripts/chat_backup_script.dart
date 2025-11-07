import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart' show debugPrint;
import 'package:gaya/services/encryption/password_encryption.dart';
import 'package:path_provider/path_provider.dart';

class ChatBackupScript {
  final _countStorage = CounterStorage();

  /// Call this function to export all chats to a file
  Future<List<Map<String, dynamic>>> exportChats({bool chatRoomsOnly = false}) async {
    final snapshotPayload = <Map<String, dynamic>>[];
    try {
      debugPrint('Fetching chatrooms...');
      final chatRooms = await _getAllChatRooms();
      debugPrint('fetched total chatrooms: ${chatRooms.length}');

      // important for blocking (async for loop)
      /// iterate over all the fetched and make file.
      for (final chatRoom in chatRooms) {
        /// if chatRoomsOnly is true, then only chatrooms will be exported
        if (chatRoomsOnly) {
          final payload = {
            'chatRoom': _makeChatRoomJson(chatRoom),
            'conversations': [],
          };
          snapshotPayload.add(payload);
        } else {
          ///  ChatRooms + conversations will be exported
          final conversations = await _getAllChats(chatRoom["chatroomId"]);
          debugPrint('total chats in convo: ${conversations.length} for chatroom: ${chatRoom["chatroomId"]}');
          final payload = {
            'chatRoom': _makeChatRoomJson(chatRoom),
            'conversations': conversations.map((conversation) {
              return _makeConversationJson(conversation);
            }).toList()
          };
          snapshotPayload.add(payload);
        }
      }

      print('total exportChats: ${snapshotPayload.length}');

      /// write to file and return the payload
      await _countStorage.writeCounter(json.encode(snapshotPayload));
    } catch (e) {
      debugPrint('Error in exportChats: $e');
      return [];
    }

    return snapshotPayload;
  }
}

/// Helper for chat backup script
extension BackupHelpers on ChatBackupScript {
  Future<List<Map<String, dynamic>>> _getAllChatRooms() async {
    final chatRooms = await FirebaseFirestore.instance.collection('chatrooms').orderBy('lastMessageTime', descending: false).get();
    return chatRooms.docs.map((doc) => doc.data()).toList();
  }

  Future<Map<String, dynamic>?> _getSingleChatRoom(String chatRoomId) async {
    final chatRoom = await FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId).get();
    return chatRoom.data();
  }

  Future<List<Map<String, dynamic>>> _getAllChats(String chatRoomId) async {
    final chats = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .get();
    return chats.docs.map((doc) => doc.data()).toList();
  }

  Map<String, dynamic> _makeConversationJson(Map<String, dynamic> conversation) {
    return {
      'messageType': conversation['messageType'],
      'sender': conversation['sender'],
      'message': EncryptData.decryptionOfLastMessage(data: conversation['message']),
    };
  }

  Map<String, dynamic> _makeChatRoomJson(Map<String, dynamic> chatRoom) {
    final chatroomPayload = {
      'id': chatRoom['chatroomId'],
      'userIds': chatRoom['userIds'],
      'lastMessageBy': chatRoom['lastMesgUserId'],
      'lastMessage': EncryptData.decryptionOfLastMessage(data: chatRoom['lastMessage']),
      // 'lastMessageAt': chatRoom['lastMessageTime'],
    };
    return chatroomPayload;
  }
}

/// Helper for writing to file
class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/backup_chat_1.json');
  }

  Future<File> writeCounter(String payload) async {
    final file = await _localFile;

    return file.writeAsString(payload);
  }
}

/////////////////////// PYTHON SCRIPT TO CONVERT TO JSON //////////////////////////////////

// import os
// import csv
// import json
//
// # Specify the directory path and file name
// directory = "/Users/badar/Documents"
// file_name = "backup_chat.json"
//
// # Read the JSON file
// with open(os.path.join(directory, file_name), 'r') as f:
// json_data = json.load(f)
//
// # Name of the CSV file to be saved
// csv_file_name = "data.csv"
// csv_file_path = os.path.join(directory, csv_file_name)
//
// # Get the header of the CSV file from the first item in the list
// header = list(json_data[0].keys())
//
// # Open a CSV file in write mode
// with open(csv_file_path, 'w', newline='') as file:
// writer = csv.writer(file)
//
// # Write the header row
// writer.writerow(['chatRoom_id', 'userIds', 'lastMessageBy', 'messageType', 'sender', 'message'])
//
// # Write each row of data
// for row in json_data:
// chat_room = row['chatRoom']
// chat_room_id = chat_room['id']
// user_ids = chat_room['userIds']
// last_message_by = chat_room['lastMessageBy']
// conversations = row['conversations']
// for conv in conversations:
// message_type = conv['messageType']
// sender = conv['sender']
// message = conv['message']
// writer.writerow([chat_room_id, user_ids, last_message_by, message_type, sender, message])
//
// print('CSV file created successfully at {}'.format(csv_file_path))
