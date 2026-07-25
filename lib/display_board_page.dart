import 'package:flutter/material.dart';
import 'chat_room_page.dart';
import 'resolution_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class DisplayBoardPage extends StatefulWidget {
  const DisplayBoardPage({super.key});

  @override
  _DisplayBoardPageState createState() => _DisplayBoardPageState();
}

class _DisplayBoardPageState extends State<DisplayBoardPage> {
  String searchQuery = ''; // To hold the search query
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initialRefreshComplaints();
  }

  void _initialRefreshComplaints() async {
    _refreshComplaints(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Chat Requests and Status
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search by Complaint ID...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (query) {
              setState(() {
                searchQuery = query.trim(); // Update the search query
              });
            },
          ),
          backgroundColor: const Color(0xFF34495E),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Chat Requests'),
              Tab(text: 'Status'),
            ],
          ),
        ),
        body: Container(
          color: const Color(0xFF34495E), // Background color
          child: TabBarView(
            children: [
              // Chat Requests Tab
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('complaints')
                    .where('status.statusText', isEqualTo: 'Investigation')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chat requests under investigation.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final complaintss = snapshot.data!.docs.where((complaint) {
                    final complaintId = complaint.id.toLowerCase();
                    final chatSession = complaint['chatSession'] ?? {};
                    final status = chatSession['status'] ?? '';

                    // Filter out complaints where chatSession status is "Closed"
                    if (status == "Closed") {
                      return false;
                    }

                    // Apply the search filter
                    return complaintId.contains(searchQuery.toLowerCase());
                  }).toList();

                  if (complaintss.isEmpty) {
                    return const Center(
                      child: Text(
                        'No complaints match your search.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: complaintss.length,
                    itemBuilder: (context, index) {
                      final complaint = complaintss[index];
                      final complaintId = complaint.id;
                      final chatSession = complaint['chatSession'] ?? {};
                      final scheduledTimeStr = chatSession['scheduledTime'] ?? '';
                      final status = chatSession['status'] ?? 'Scheduled';

                      String formattedTime = scheduledTimeStr;
                      if (scheduledTimeStr.isNotEmpty) {
                        try {
                          final scheduledTime = DateTime.parse(scheduledTimeStr).toLocal();
                          final formatter = DateFormat('dd/MM/yyyy hh:mm a');
                          formattedTime = formatter.format(scheduledTime);
                        } catch (e) {
                          print('Error parsing scheduledTime: $e');
                        }
                      }

                      final messages = chatSession['messages'] ?? [];
                      final hasUnreadMessages = messages.any((message) =>
                      message['sender'] == 'panel' && message['isRead'] == false);

                      return ChatRequestCard(
                        title: complaintId,
                        complaintId: complaintId,
                        isAvailable: status == 'Available',
                        time: formattedTime,
                        hasUnreadMessages: hasUnreadMessages,
                      );
                    },
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('complaints')
                      .where('status.statusText', isEqualTo: 'Resolved') // Fetch resolved complaints
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No resolved complaints available.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    // Apply the search filter
                    final resolvedComplaints = snapshot.data!.docs.where((complaint) {
                      final complaintId = complaint.id.toLowerCase();

                      // Apply the search filter for the status tab
                      return complaintId.contains(searchQuery.toLowerCase());
                    }).toList();

                    if (resolvedComplaints.isEmpty) {
                      return const Center(
                        child: Text(
                          'No complaints match your search.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: resolvedComplaints.length,
                      itemBuilder: (context, index) {
                        final complaint = resolvedComplaints[index];
                        final complaintId = complaint.id;

                        return StatusCard(
                          status: 'Resolved',
                          title: '$complaintId ',

                          onTap: () {
                            _showTokenDialog(context, complaintId,() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResolutionPage(complaintId: complaintId),
                                ),
                              );
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Status Tab (No changes here)
            ],
          ),
        ),
      ),
    );
  }
}


void _refreshComplaints(BuildContext context) async {
  final complaintsQuery = await FirebaseFirestore.instance
      .collection('complaints')
      .where('status.statusText', isEqualTo: 'Investigation')
      .get();

  for (var complaint in complaintsQuery.docs) {
    final complaintId = complaint.id;
    final chatSession = complaint['chatSession'] ?? {};
    final scheduledTimeStr = chatSession['scheduledTime'] ?? '';
    final status = chatSession['status'] ?? 'Scheduled';

    if (status == 'Scheduled' && scheduledTimeStr.isNotEmpty) {
      try {
        // Parse scheduled time and compare with the current time
        final scheduledTime = DateTime.parse(scheduledTimeStr).toLocal();

        if (DateTime.now().isAfter(scheduledTime)) {
          await FirebaseFirestore.instance
              .collection('complaints')
              .doc(complaintId)
              .update({'chatSession.status': 'Available'});
        }
      } catch (e) {
        print('Error updating status for $complaintId: $e');
      }
    }
  }
}


class ChatRequestCard extends StatelessWidget {
  final String title;
  final String complaintId;
  final bool isAvailable;
  final String time;
  final bool hasUnreadMessages; // New flag

  const ChatRequestCard({
    super.key,
    required this.title,
    required this.complaintId,
    this.isAvailable = false,
    required this.time,
    this.hasUnreadMessages = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: isAvailable
                          ? ' - Chat Open'
                          : ' - Panel scheduled a meeting for $time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
                        color: isAvailable ? Colors.blue : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasUnreadMessages) ...[
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 5,
                backgroundColor: Colors.red, // Red dot for unread messages
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward, color: Color(0xFF1ABC9C)),
        onTap: () async {
          final complaintDoc = await FirebaseFirestore.instance
              .collection('complaints')
              .doc(complaintId)
              .get();

          if (complaintDoc.exists) {
            final scheduledTimeStr = complaintDoc['chatSession']['scheduledTime'];
            final scheduledTime = DateTime.parse(scheduledTimeStr).toLocal();
            final currentTime = DateTime.now();

            if (currentTime.isBefore(scheduledTime)) {
              _showMessage(context, 'The scheduled time for this complaint has not yet arrived.');
              return;
            } else {
              _showTokenDialog(context, complaintId, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomPage(complaintId: complaintId),
                  ),
                );
              });
            }
          }// Your existing logic here
        },
      ),
    );
  }
}


  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }




class StatusCard extends StatelessWidget {
  final String status;
  final String title;
  final VoidCallback? onTap;

  const StatusCard({super.key, required this.status, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Chip(
          label: Text(
            status,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: status == 'Resolved' ? const Color(0xFF1ABC9C) : Colors.orange,
        ),
        onTap: onTap,
      ),
    );
  }
}
void _showTokenDialog(BuildContext context,String complaintId, VoidCallback onValidToken) {
  final TextEditingController tokenController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF34495E),
        title: const Text(
          'Enter Token Number',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: tokenController,
          decoration: const InputDecoration(
            hintText: 'Enter token number',
            hintStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF1ABC9C))),
          ),
          TextButton(
            onPressed: () async {
              final enteredToken = tokenController.text.trim();
              final isValidToken = await _validateToken(complaintId, enteredToken);
              Navigator.of(context).pop();
              if (isValidToken) {
                onValidToken();
                markMessagesAsRead(complaintId);
              } else {
                _showInvalidTokenMessage(context);
              }
            },
            child: const Text('Submit', style: TextStyle(color: Color(0xFF1ABC9C))),
          ),
        ],
      );
    },
  );
}
Future<bool> _validateToken(String complaintId, String enteredToken) async {
  try {
    final complaintDoc = await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .get();

    if (complaintDoc.exists) {
      final tokenNumber = complaintDoc['tokenNumber'];
      return tokenNumber == enteredToken;
    }
  } catch (e) {
  }
  return false; // Return false if validation fails
}
void _showInvalidTokenMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Invalid token number'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ),
  );
}
void markMessagesAsRead(String complaintId) async {
  final complaintDoc = await FirebaseFirestore.instance
      .collection('complaints')
      .doc(complaintId)
      .get();

  if (complaintDoc.exists) {
    final messages = complaintDoc['chatSession']['messages'] as List;

    final updatedMessages = messages.map((message) {
      if (message['sender'] == 'panel' && message['isRead'] == false) {
        message['isRead'] = true;
      }
      return message;
    }).toList();

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintId)
        .update({
      "chatSession.messages": updatedMessages
    });
  }
}


