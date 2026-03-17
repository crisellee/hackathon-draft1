import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/providers.dart';

class AIAdminContact extends ConsumerStatefulWidget {
  const AIAdminContact({super.key});

  @override
  ConsumerState<AIAdminContact> createState() => _AIAdminContactState();
}

class _AIAdminContactState extends ConsumerState<AIAdminContact> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, String>> _messages = [
    {
      "role": "ai",
      "message": "Hello 👋 I am the AI Admin Assistant. How can I help you today?"
    }
  ];

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    final studentId = ref.read(userIdProvider) ?? 'anonymous';

    setState(() {
      _messages.add({
        "role": "user",
        "message": userMessage,
      });
    });

    // Save student message to Firestore
    await _firestore.collection('support_chats').add({
      'id': const Uuid().v4(),
      'studentId': studentId,
      'message': userMessage,
      'role': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 600), () async {
      final aiReply = _generateAIResponse(userMessage);

      setState(() {
        _messages.add({
          "role": "ai",
          "message": aiReply,
        });
      });

      // Save AI reply to Firestore
      await _firestore.collection('support_chats').add({
        'id': const Uuid().v4(),
        'studentId': studentId,
        'message': aiReply,
        'role': 'ai',
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  String _generateAIResponse(String message) {
    final msg = message.toLowerCase();
    if (msg.contains("submit")) {
      return "To submit a concern, please open the Student Form and press the SUBMIT CONCERN button after filling in the details.";
    }
    if (msg.contains("status")) {
      return "You can check the status of your concern in the Student Dashboard under your tracked concerns.";
    }
    if (msg.contains("anonymous")) {
      return "Yes, you can submit concerns anonymously by turning on the 'Submit Anonymously' switch.";
    }
    if (msg.contains("department")) {
      return "Select the correct department (COA, COE, CCS, CBAE) so the concern will be routed to the appropriate staff.";
    }
    if (msg.contains("attachment")) {
      return "You may attach files when submitting a concern. Just click the SELECT button in the attachment section.";
    }
    return "I can help you with submitting concerns, tracking cases, and system questions. Please ask your question.";
  }

  Widget _buildMessage(Map<String, String> msg) {
    final isUser = msg["role"] == "user";
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Colors.red : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg["message"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Admin (AI Assistant)"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Ask the AI Admin...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.red),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
