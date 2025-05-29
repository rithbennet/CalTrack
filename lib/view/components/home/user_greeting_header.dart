import 'package:flutter/material.dart';
import 'package:caltrack/models/user_model.dart';

class UserGreetingHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final UserModel? userProfile;
  final VoidCallback onAvatarTap;

  const UserGreetingHeader({
    super.key,
    required this.greeting,
    required this.userName,
    this.userProfile,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 50,
          child: GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.deepOrange.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child:
                  userProfile?.photoURL != null
                      ? ClipOval(
                        child: Image.network(
                          userProfile!.photoURL!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                            );
                          },
                        ),
                      )
                      : const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
