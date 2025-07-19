// lib/data/models/user_profile.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final DateTime? birthDate;
  final String? sex;
  final String? timeZone;
  final String? goal;

  UserProfile({
    required this.uid,
    required this.email,
    this.birthDate,
    this.sex,
    this.timeZone,
    this.goal,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      sex: data['sex'],
      timeZone: data['timeZone'],
      goal: data['goal'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate!),
      if (sex != null) 'sex': sex,
      if (timeZone != null) 'timeZone': timeZone,
      if (goal != null) 'goal': goal,
    };
  }
}