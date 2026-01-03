import 'package:airlift/app/ui/screens/caht/massegebubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;

  const ChatScreen({super.key, required this.peerId, required this.peerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  void sendMessage() {
    if (msgController.text.trim().isEmpty) return;
    FirebaseFirestore.instance.collection('chats').add({
      'senderId': currentUser.uid,
      'receiverId': widget.peerId,
      'message': msgController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.peerName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('senderId', whereIn: [currentUser.uid, widget.peerId])
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs
                    .where((doc) =>
                        (doc['senderId'] == currentUser.uid && doc['receiverId'] == widget.peerId) ||
                        (doc['senderId'] == widget.peerId && doc['receiverId'] == currentUser.uid))
                    .toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == currentUser.uid;
                    return MessageBubble(message: msg['message'], isMe: isMe);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: msgController,
                    decoration: const InputDecoration(
                        hintText: "Type a message", border: OutlineInputBorder()),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          )
        ],
      ),
    );
  }
}
