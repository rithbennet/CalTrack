import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';
import 'package:caltrack/viewmodels/user_view_model.dart';
import 'package:caltrack/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    if (authViewModel.currentUser != null) {
      userViewModel.loadUserProfile(authViewModel.currentUser!.id);
      // Set the initial display name
      final userProfile = userViewModel.userProfile;
      final currentUser = authViewModel.currentUser;
      _displayNameController.text =
          userProfile?.displayName ?? currentUser?.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;

    if (currentUser != null) {
      // Create updated user model
      final updatedUser = UserModel(
        id: currentUser.id,
        email: currentUser.email,
        displayName: _displayNameController.text.trim(),
        photoURL: userViewModel.userProfile?.photoURL ?? currentUser.photoURL,
        createdAt: userViewModel.userProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await userViewModel.createOrUpdateUserProfile(
        updatedUser,
      );

      if (success && mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userViewModel.errorMessage.isNotEmpty
                  ? userViewModel.errorMessage
                  : 'Failed to update profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, UserViewModel>(
      builder: (context, authViewModel, userViewModel, child) {
        final currentUser = authViewModel.currentUser;
        final userProfile = userViewModel.userProfile;

        final userName =
            userProfile?.displayName ??
            currentUser?.displayName ??
            (currentUser != null && currentUser.email.isNotEmpty
                ? currentUser.email.split('@').first
                : 'User');

        return Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            title: const Text('Profile'),
            elevation: 0,
            actions: [
              if (!_isEditing)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              if (_isEditing)
                IconButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.save),
                ),
              if (_isEditing)
                IconButton(
                  onPressed:
                      _isSaving
                          ? null
                          : () {
                            setState(() {
                              _isEditing = false;
                              // Reset the display name
                              _displayNameController.text =
                                  userProfile?.displayName ??
                                  currentUser?.displayName ??
                                  '';
                            });
                          },
                  icon: const Icon(Icons.cancel),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Profile Avatar
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.deepOrange,
                              width: 3,
                            ),
                          ),
                          child:
                              userProfile?.photoURL != null
                                  ? ClipOval(
                                    child: Image.network(
                                      userProfile!.photoURL!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // User Name Display
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      currentUser?.email ?? 'No email',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),

                    const SizedBox(height: 40),

                    // Profile Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Display Name Field
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Display Name',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _displayNameController,
                                  enabled: _isEditing,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your display name',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border:
                                        _isEditing
                                            ? OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: Colors.grey[600]!,
                                              ),
                                            )
                                            : InputBorder.none,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[600]!,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                    filled: _isEditing,
                                    fillColor:
                                        _isEditing
                                            ? Colors.grey[800]
                                            : Colors.transparent,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Display name cannot be empty';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'Display name must be at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Account Information
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Information',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildReadOnlyInfoRow(
                                  'Email',
                                  currentUser?.email ?? 'Not available',
                                ),
                                const SizedBox(height: 16),
                                _buildReadOnlyInfoRow(
                                  'User ID',
                                  currentUser?.id ?? 'Unknown',
                                ),
                                const SizedBox(height: 16),
                                _buildReadOnlyInfoRow(
                                  'Member Since',
                                  userProfile?.createdAt != null
                                      ? _formatDate(userProfile!.createdAt!)
                                      : 'Recently joined',
                                ),
                                if (userProfile?.updatedAt != null) ...[
                                  const SizedBox(height: 16),
                                  _buildReadOnlyInfoRow(
                                    'Last Updated',
                                    _formatDate(userProfile!.updatedAt!),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isEditing
                                      ? null
                                      : () async {
                                        // Show confirmation dialog
                                        final shouldLogout = await showDialog<
                                          bool
                                        >(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text(
                                                  'Confirm Logout',
                                                ),
                                                content: const Text(
                                                  'Are you sure you want to log out?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.of(
                                                          context,
                                                        ).pop(true),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text('Logout'),
                                                  ),
                                                ],
                                                backgroundColor:
                                                    Colors.grey[900],
                                                titleTextStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                contentTextStyle:
                                                    const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 16,
                                                    ),
                                              ),
                                        );

                                        // If user confirms logout
                                        if (shouldLogout == true &&
                                            context.mounted) {
                                          // Show a loading indicator
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('Logging out...'),
                                            ),
                                          );

                                          // Call the signOut method from AuthViewModel
                                          await authViewModel.signOut();
                                        }
                                      },
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
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
