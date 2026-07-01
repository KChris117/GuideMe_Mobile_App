import 'package:flutter/material.dart';
import 'package:guideme/models/user_model.dart';

class UserTable extends StatelessWidget {
  final UserModel user;

  const UserTable({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: user.profilePicture.isNotEmpty
                  ? NetworkImage(user.profilePicture)
                  : AssetImage('assets/images/default_avatar.png') as ImageProvider,
            ),
            SizedBox(height: 20),

            // User Details Card
            Card(              
              color: Colors.white, // Background color of the card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRowWithDivider('Username', user.username),
                    SizedBox(height: 10),
                    _buildDetailRowWithDivider('Email', user.email),
                    SizedBox(height: 10),
                    _buildDetailRowWithDivider('Role', user.role),
                    SizedBox(height: 10),
                    _buildDetailRowWithDivider('UID', user.uid),
                    SizedBox(height: 10),
                    _buildDetailRowWithDivider('Created At', user.createdAt.toDate().toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRowWithDivider(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      SizedBox(height: 8), // Jarak antara teks dan garis
      Divider(
        color: Colors.grey[300],
        thickness: 1,
      ),
      SizedBox(height: 8), // Jarak antara garis dan item berikutnya
    ],
  );
}
}
