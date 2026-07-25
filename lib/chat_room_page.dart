import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomPage extends StatefulWidget {
  final String complaintId;

  const ChatRoomPage({Key? key, required this.complaintId}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CollectionReference _complaintsCollection;
  bool _initialScrollDone = false; // Tracks if the initial scroll is completed

  @override
  void initState() {
    super.initState();
    _complaintsCollection = FirebaseFirestore.instance.collection('complaints');

    // Listen to scroll position changes
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        // Set the flag if the user is at the top or bottom
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
          _initialScrollDone = true;
        }
      }
    });
  }

  Future<void> sendMessage() async {
    if (_chatController.text.isNotEmpty) {
      final now = DateTime.now();
      final newMessage = {
        "sender": "user",
        "content": _chatController.text,
        "timestamp": now.toIso8601String(),
        "isRead": false, // Add the isRead field with a default value of false
      };

      await _complaintsCollection.doc(widget.complaintId).update({
        "chatSession.messages": FieldValue.arrayUnion([newMessage]),
        "chatSession.lastActivity": now.toIso8601String(), // Update lastActivity
      });

      _chatController.clear();

      // Scroll to the bottom after sending a message
      scrollToBottom();
    }
  }



  Stream<List<Map<String, dynamic>>> fetchMessages() {
    return _complaintsCollection.doc(widget.complaintId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return [];
      final data = snapshot.data() as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['chatSession']['messages']);
    });
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Chat Room'),
        backgroundColor: const Color(0xFF34495E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F5FA), // Light background for the chat area
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final messages = snapshot.data!;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_initialScrollDone && _scrollController.hasClients) {
                      Future.microtask(() {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                        _initialScrollDone = true;
                      });
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    reverse: false,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message['sender'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[300] : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            message['content'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )

            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1ABC9C),
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
