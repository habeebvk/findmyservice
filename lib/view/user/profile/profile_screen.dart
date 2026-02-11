import 'package:findmyservicesapp/view/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.orange,
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 50,
                            backgroundImage:
                                user?.profilePic != null &&
                                    user!.profilePic!.isNotEmpty
                                ? (user.profilePic!.startsWith('http')
                                      ? NetworkImage(user.profilePic!)
                                      : FileImage(File(user.profilePic!))
                                            as ImageProvider)
                                : null,
                            child:
                                user?.profilePic == null ||
                                    user!.profilePic!.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? "Guest",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?.email ?? "No Email",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Profile options
            _buildProfileOption(Icons.person, "Edit Profile", () {
              _showEditProfileDialog(context);
            }),
            _buildProfileOption(Icons.settings, "Settings", () {}),
            _buildProfileOption(Icons.help, "Help & Support", () {}),
            _buildProfileOption(Icons.logout, "Logout", () {
              _showLogoutDialog(context);
            }),

            const SizedBox(height: 20),

            // About App
            const Text(
              "App Version 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _pickImage() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        password: user.password,
        role: user.role,
        workType: user.workType,
        profilePic: image.path,
      );

      final result = await _databaseService.updateUser(updatedUser);
      if (result != -1) {
        AuthService().updateCurrentUser(updatedUser);
        setState(() {});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated!")),
          );
        }
      }
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = AuthService().currentUser;
    final nameController = TextEditingController(text: user?.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (user != null) {
                final updatedUser = UserModel(
                  id: user.id,
                  name: nameController.text,
                  email: user.email,
                  password: user.password,
                  role: user.role,
                  workType: user.workType,
                  profilePic: user.profilePic,
                );

                final result = await _databaseService.updateUser(updatedUser);
                if (result != -1) {
                  AuthService().updateCurrentUser(updatedUser);
                  setState(() {});
                  if (mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile updated successfully!"),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to update profile")),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              AuthService().logout();
              // Navigate to login page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }
}
