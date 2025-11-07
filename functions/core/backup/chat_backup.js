const admin = require('firebase-admin');
const db = admin.firestore();
const decryptor = require('../encryption/aes');


const _getAllChatRooms = async () => {
    const chatRooms = await db.collection('chatrooms').limit(10).get();
    return chatRooms.docs;
}
const _getSingleChatRoom = async (chatRoomId) => {
    const chatRoom = await db.collection('chatrooms').doc(chatRoomId).get();
    return chatRoom;
}
const _getAllChats = async (chatRoomId) => {
    const chats = await db.collection('chatrooms').doc(chatRoomId).collection('messages').get();
    return chats.docs;
}
const exportChats = async () => {
    var snapshotPayload = [];

    // const chatRoom = await _getSingleChatRoom('0pOrBZzPIeeCcv8KUheKh3BFGKo17umffRgdkpRk8X4hPJgcTySyR8s2');
    const chatRooms = await _getAllChatRooms();
    console.log("Fetching chatrooms...");
    // important for blocking (async for loop)
    for await (const chatRoom of chatRooms) {

        const conversations = await _getAllChats(chatRoom.id);
        const payload = {
            chatRoom: _makeChatRoomJson(chatRoom),
            conversations: conversations.map((conversation) => {
                return _makeConversationJson(conversation);
            })
        }
        snapshotPayload.push(payload);
    }

    console.log("snapshotPayload: ", snapshotPayload);

    return snapshotPayload;

}


/**
 * Makes a json object of a conversation and returns it
 * @param {Object} conversation
 */
_makeConversationJson = (conversation) => {

    return {
        messageType: conversation.data().messageType,
        sender: conversation.data().sender,
        message:conversation.data().message
    }
}

/**
 * Makes a json object of a chatroom and returns it
 * @param {Object} chatRoom
 */
_makeChatRoomJson = (chatRoom) => {
    const chatroomPayload = {
        id: chatRoom.id,
        userIds: chatRoom.data().userIds,
        lastMessageBy: chatRoom.data().lastMesgUserId,
        lastMessageAt: chatRoom.data().lastMessageTime,
    }
    return chatroomPayload;
}

module.exports = { exportChats };
