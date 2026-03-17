import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/concern.dart';
import '../models/comment.dart';
import '../services/concern_service.dart';
import 'package:intl/intl.dart';

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
class ConcernDetailScreen extends ConsumerStatefulWidget {
  final Concern concern;
  final bool isAdmin;

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  const ConcernDetailScreen({
    super.key,
    required this.concern,
    this.isAdmin = false,
  });

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  @override
  ConsumerState<ConcernDetailScreen> createState() => _ConcernDetailScreenState();
}

<<<<<<< HEAD
class _ConcernDetailScreenState extends ConsumerState<ConcernDetailScreen> {
  final _commentController = TextEditingController();

=======

class _ConcernDetailScreenState extends ConsumerState<ConcernDetailScreen> {
  final _commentController = TextEditingController();


>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

=======

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;


>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
    final comment = Comment(
      id: const Uuid().v4(),
      concernId: widget.concern.id,
      senderId: widget.isAdmin ? 'admin_id' : widget.concern.studentId,
      senderName: widget.isAdmin ? 'Admin/Staff' : (widget.concern.isAnonymous ? 'Anonymous Student' : widget.concern.studentName),
      message: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
    await ref.read(concernServiceProvider).addComment(comment);
    _commentController.clear();
  }

<<<<<<< HEAD
  void _updateStatus(ConcernStatus status) async {
    await ref.read(concernServiceProvider).updateStatus(widget.concern.id, status, 'admin_user');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to ${status.name.toUpperCase()}')),
      );
    }
  }
=======
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2

  @override
  Widget build(BuildContext context) {
    final commentsStream = ref.watch(concernServiceProvider).getComments(widget.concern.id);

<<<<<<< HEAD
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.concern.id.substring(0, 8).toUpperCase()),
=======

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.concern.title),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
<<<<<<< HEAD
          // Basic Info Header
          _buildConcernHeader(),
          
          // Chat Area
=======
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: commentsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                }
<<<<<<< HEAD
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text('No messages yet.', style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isMe = comment.senderId == (widget.isAdmin ? 'admin_id' : widget.concern.studentId);
=======

                final comments = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildConcernInfo();
                    }
                    final comment = comments[index - 1];
                    final isMe = comment.senderId == (widget.isAdmin ? 'admin_id' : widget.concern.studentId);

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
                    return _buildCommentBubble(comment, isMe);
                  },
                );
              },
            ),
          ),
<<<<<<< HEAD

          // Message Input
          _buildCommentInput(),

          // Admin Status Choices (If Admin)
          if (widget.isAdmin) _buildAdminStatusActions(),
=======
          _buildCommentInput(),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildConcernHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.concern.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(widget.concern.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
=======

  Widget _buildConcernInfo() {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: \${widget.concern.category.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.concern.description),
            const Divider(height: 24),
            const Text('Interaction History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
      ),
    );
  }

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  Widget _buildCommentBubble(Comment comment, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: isMe ? Colors.red : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(comment.senderName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 2),
            Text(comment.message, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(comment.timestamp),
              style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Colors.grey),
=======
          color: isMe ? Colors.red.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.senderName,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isMe ? Colors.red : Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(comment.message),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(comment.timestamp),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
=======

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
<<<<<<< HEAD
              decoration: const InputDecoration(hintText: 'Type your message...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.red), onPressed: _sendComment),
        ],
      ),
    );
  }

  Widget _buildAdminStatusActions() {
    // Only show relevant status updates for admin
    final statuses = [
      ConcernStatus.read,
      ConcernStatus.screened,
      ConcernStatus.resolved,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('UPDATE STATUS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(s.name.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[300]!),
                  onPressed: () => _updateStatus(s),
                ),
              )).toList(),
            ),
=======
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.red),
            onPressed: _sendComment,
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
          ),
        ],
      ),
    );
  }
}
<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
