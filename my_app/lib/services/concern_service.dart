import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
=======
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/concern.dart';
import '../models/audit_trail.dart';
import '../models/comment.dart';
import 'notification_service.dart';

<<<<<<< HEAD
final concernServiceProvider = Provider((ref) => ConcernService());

=======

final concernServiceProvider = Provider((ref) => ConcernService());


>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
class ConcernService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notifications = NotificationService();
  final _uuid = const Uuid();

<<<<<<< HEAD
=======

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  Future<void> submitConcern(Concern concern) async {
    final docRef = _db.collection('concerns').doc(concern.id);

    try {
<<<<<<< HEAD
      await docRef.set(concern.toMap());
      
      await _logAction(
        concernId: concern.id,
        actorId: concern.studentId,
        action: 'SUBMITTED',
        details: 'Concern submitted in category: ${concern.category.name.toUpperCase()}',
      );

      _notifications.sendStatusUpdateNotification(
          concern.studentId,
          concern.title,
          'Your concern has been submitted successfully.'
      );

      await _executeAutoRouting(concern);
    } catch (e) {
      debugPrint("Firestore Submit Error: $e");
    }
  }

  Future<void> addComment(Comment comment) async {
    try {
      await _db.collection('comments').doc(comment.id).set(comment.toMap());
      await _logAction(
        concernId: comment.concernId,
        actorId: comment.senderId,
        action: 'MESSAGE',
        details: 'New message from ${comment.senderName}',
      );
    } catch (e) {
      debugPrint("Comment error: $e");
    }
  }

=======
      // Step 1: Save the original concern from student form
      await docRef.set(concern.toMap());
    } catch (e) {
      print("Firestore Error: \$e");
    }


    _logAction(
      concernId: concern.id,
      actorId: concern.studentId,
      action: 'Submitted',
      details: 'Concern submitted in category: \${concern.category.name} for department: \${concern.department}',
    );


    _notifications.sendStatusUpdateNotification(
        concern.studentId,
        concern.title,
        'Submitted successfully'
    );


    // Step 2: Update status to ROUTED without overwriting the student's department choice
    _routeConcern(concern.id, concern.department);
  }


  Future<void> addComment(Comment comment) async {
    try {
      await _db.collection('comments').doc(comment.id).set(comment.toMap());
    } catch (e) {
      print("Comment error: \$e");
    }

    _logAction(
      concernId: comment.concernId,
      actorId: comment.senderId,
      action: 'Comment',
      details: 'New comment from \${comment.senderName}',
    );
  }


>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  Stream<List<Comment>> getComments(String concernId) {
    return _db.collection('comments')
        .where('concernId', isEqualTo: concernId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Comment.fromMap(doc.data(), doc.id)).toList());
  }

<<<<<<< HEAD
  Future<void> _executeAutoRouting(Concern concern) async {
    String targetDept = 'GENERAL ADMINISTRATION';
    switch (concern.category) {
      case ConcernCategory.academic:
        targetDept = "DEAN'S OFFICE";
        break;
      case ConcernCategory.financial:
        targetDept = "BURSAR OFFICE";
        break;
      case ConcernCategory.welfare:
        targetDept = "STUDENT SERVICES";
        break;
    }

    try {
      await _db.collection('concerns').doc(concern.id).update({
        'status': ConcernStatus.routed.name,
        'assignedTo': targetDept,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await _logAction(
        concernId: concern.id,
        actorId: 'SYSTEM',
        action: 'ROUTED',
        details: 'Automatically routed to $targetDept based on category.',
      );
    } catch (e) {
      debugPrint("Routing error: $e");
    }
  }

  Future<void> updateStatus(String id, ConcernStatus status, String actorId) async {
    try {
      final updates = {
        'status': status.name,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };
      
      if (status == ConcernStatus.read) updates['readAt'] = FieldValue.serverTimestamp();
      if (status == ConcernStatus.resolved) updates['resolvedAt'] = FieldValue.serverTimestamp();

      await _db.collection('concerns').doc(id).update(updates);

      await _logAction(
        concernId: id,
        actorId: actorId,
        action: 'STATUS_UPDATE',
        details: 'Status changed to ${status.name.toUpperCase()}',
      );
    } catch (e) {
      debugPrint("Status update error: $e");
    }
  }

  Future<void> enforceSLA() async {
    final now = DateTime.now();
    try {
      final routedSnapshot = await _db.collection('concerns')
          .where('status', isEqualTo: ConcernStatus.routed.name).get();

      for (var doc in routedSnapshot.docs) {
        final concern = Concern.fromMap(doc.data(), doc.id);
        if (now.difference(concern.createdAt).inDays >= 2) {
          await _escalateSLA(concern, 'AUTO-ESCALATION: No response for >2 days.');
        }
      }

      final readSnapshot = await _db.collection('concerns')
          .where('status', isEqualTo: ConcernStatus.read.name).get();

      for (var doc in readSnapshot.docs) {
        final concern = Concern.fromMap(doc.data(), doc.id);
        if (concern.lastUpdatedAt != null && now.difference(concern.lastUpdatedAt!).inDays >= 5) {
          await _escalateSLA(concern, 'AUTO-ESCALATION: No screening for >5 days.');
        }
      }
    } catch (e) {
      debugPrint("SLA Audit Error: $e");
    }
  }

=======

  Future<void> _routeConcern(String id, String chosenDepartment) async {
    try {
      await _db.collection('concerns').doc(id).update({
        'status': ConcernStatus.routed.name,
        'assignedTo': chosenDepartment, // Use the department chosen in the form
        'lastUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      print("Routing error: \$e");
    }


    _logAction(
      concernId: id,
      actorId: 'system',
      action: 'Routed',
      details: 'Concern routed to \$chosenDepartment department as requested',
    );
  }


  Future<void> updateAssignedDepartment(String id, String department, String actorId) async {
    try {
      await _db.collection('concerns').doc(id).update({
        'assignedTo': department,
        'lastUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      print("Update department error: \$e");
    }


    _logAction(
      concernId: id,
      actorId: actorId,
      action: 'Department Update',
      details: 'Concern re-assigned to \$department department',
    );
  }


  Future<void> updateStatus(String id, ConcernStatus status, String actorId) async {
    String details = 'Status changed to \${status.name}';

    try {
      await _db.collection('concerns').doc(id).update({
        'status': status.name,
        'lastUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      print("Status update error: \$e");
    }


    _logAction(
      concernId: id,
      actorId: actorId,
      action: 'Status Update',
      details: details,
    );
  }


  Future<void> checkSLAEnforcement() async {
    final now = DateTime.now();

    final routedSnapshot = await _db.collection('concerns')
        .where('status', isEqualTo: ConcernStatus.routed.name)
        .get();


    for (var doc in routedSnapshot.docs) {
      final concern = Concern.fromMap(doc.data(), doc.id);
      if (now.difference(concern.createdAt).inDays >= 2) {
        _escalateSLA(concern, 'Auto-escalated due to >2 days in Routed status.');
      }
    }
  }


>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  Future<void> _escalateSLA(Concern concern, String reason) async {
    try {
      await _db.collection('concerns').doc(concern.id).update({
        'status': ConcernStatus.escalated.name,
<<<<<<< HEAD
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      });

      await _logAction(
        concernId: concern.id,
        actorId: 'SYSTEM_SLA',
        action: 'ESCALATION',
        details: reason,
      );
    } catch (e) {
      debugPrint("Escalation error: $e");
    }
  }

=======
        'lastUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      print("Escalation error: \$e");
    }


    _logAction(
      concernId: concern.id,
      actorId: 'system_sla',
      action: 'SLA Escalation',
      details: reason,
    );
  }


>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
  Future<void> _logAction({
    required String concernId,
    required String actorId,
    required String action,
    required String details,
  }) async {
    final logId = _uuid.v4();
    final log = AuditLog(
      id: logId,
      concernId: concernId,
      actorId: actorId,
      action: action,
      timestamp: DateTime.now(),
      details: details,
    );
<<<<<<< HEAD
    await _db.collection('audit_logs').doc(logId).set(log.toMap());
  }

  Stream<List<Concern>> streamAllConcerns() {
=======
    try {
      await _db.collection('audit_logs').doc(logId).set(log.toMap());
    } catch (e) {
      print("Log action error: \$e");
    }
  }


  Stream<List<Concern>> getConcerns() {
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
    return _db.collection('concerns').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Concern.fromMap(doc.data(), doc.id)).toList(),
    );
  }

<<<<<<< HEAD
  Stream<List<Concern>> getConcerns() {
    return streamAllConcerns();
  }
=======
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2

  Stream<List<Concern>> getConcernsByStudent(String studentId) {
    return _db.collection('concerns')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Concern.fromMap(doc.data(), doc.id)).toList());
  }

<<<<<<< HEAD
  Stream<List<Concern>> streamConcernsByStudent(String studentId) {
    return getConcernsByStudent(studentId);
  }

  Stream<List<AuditLog>> streamAuditTrail(String concernId) {
=======

  Stream<List<AuditLog>> getAuditTrail(String concernId) {
>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
    return _db.collection('audit_logs')
        .where('concernId', isEqualTo: concernId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AuditLog.fromMap(doc.data(), doc.id)).toList());
  }
<<<<<<< HEAD

  Stream<List<AuditLog>> getAuditTrail(String concernId) {
    return streamAuditTrail(concernId);
  }

  Future<void> checkSLAEnforcement() async {
    return enforceSLA();
  }
}
=======
}

>>>>>>> c3e067d78a3dd4cf7368b66f56c38a2e71ca3da2
