import 'package:flutter/material.dart';
import '../domain/student.dart';

class StudentDetailsPage extends StatelessWidget {
  final Student student;
  const StudentDetailsPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails étudiant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'st_${student.id}',
                  child: CircleAvatar(
                      radius: 28,
                      child: Text(student.firstName.isNotEmpty
                          ? student.firstName[0]
                          : '?')),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.fullName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Massar: ${student.massar}'),
                      Text('Groupe ID: ${student.groupId}'),
                      if (student.email != null)
                        Text('Email: ${student.email}'),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
