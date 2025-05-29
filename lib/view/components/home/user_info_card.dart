import 'package:flutter/material.dart';
import 'package:caltrack/models/user_model.dart';

class UserInfoCard extends StatelessWidget {
  final UserModel? currentUser;
  final UserModel? userProfile;

  const UserInfoCard({super.key, this.currentUser, this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow('Email', currentUser?.email ?? 'Not available'),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Display Name',
            userProfile?.displayName ?? currentUser?.displayName ?? 'Not set',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Member Since',
            userProfile?.createdAt != null
                ? _formatDate(userProfile!.createdAt!)
                : 'Recently joined',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
