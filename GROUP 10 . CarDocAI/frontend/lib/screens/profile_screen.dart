import 'package:flutter/material.dart';
import 'package:cardocai/screens/personal_info_screen.dart';
import 'package:cardocai/screens/change_password_screen.dart';
import 'package:cardocai/screens/login_screen.dart';
import 'package:cardocai/screens/settings_screen.dart';
import 'package:cardocai/screens/help_about_screen.dart';
import 'package:cardocai/screens/diagnosis_history_screen.dart';
import 'package:cardocai/screens/home_screen.dart';
import 'package:cardocai/services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Remove hardcoded values - will be loaded from database
  String userName = '';
  String userRole = '';
  String userEmail = '';
  String userAvatar = 'assets/images/default_avatar.png';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load real user data from Supabase
  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        // User not logged in, redirect to login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      // Fetch user data with profile
      final response = await client
          .from('users')
          .select('''
            *,
            user_profiles (*)
          ''')
          .eq('user_id', user.id)
          .single();

      if (mounted) {
        final userData = response;
        final profileData = userData['user_profiles'][0] as Map<String, dynamic>?;

        setState(() {
          userEmail = userData['email'] ?? '';
          userRole = userData['role'] ?? 'Driver';
          
          // Get name from profile data
          if (profileData != null) {
            final firstName = profileData['first_name'] ?? '';
            final lastName = profileData['last_name'] ?? '';
            userName = '$firstName $lastName'.trim();
            if (userName.isEmpty) {
              userName = userEmail.split('@').first; // Fallback to email username
            }
          } else {
            userName = userEmail.split('@').first; // Fallback to email username
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          // Set fallback values
          userName = 'User';
          userRole = 'Driver';
          userEmail = '';
        });
      }
    }
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: TextEditingController(text: userName),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  userName = value;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: userRole.toLowerCase(),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'driver', child: Text('Driver')),
                  DropdownMenuItem(value: 'mechanic', child: Text('Mechanic')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    userRole = value.substring(0, 1).toUpperCase() + value.substring(1);
                  }
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _saveProfileChanges(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Save profile changes to Supabase
  Future<void> _saveProfileChanges() async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) return;

      // Split name into first and last name
      final nameParts = userName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Update user role in users table
      await client
          .from('users')
          .update({
            'role': userRole.toLowerCase(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);

      // Update or insert user profile
      await client
          .from('user_profiles')
          .upsert({
            'user_id': user.id,
            'first_name': firstName,
            'last_name': lastName,
            'updated_at': DateTime.now().toIso8601String(),
          });

      if (mounted) {
        Navigator.pop(context); // Close the modal
        setState(() {}); // Refresh the UI
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await SupabaseService.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                print('❌ Logout error: $e');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Logout failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading profile...'),
                  ],
                ),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load profile',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Profile Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Avatar and Edit Button
                                    Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.2),
                                              width: 3,
                                            ),
                                            image: DecorationImage(
                                              image: AssetImage(userAvatar),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: _editProfile,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      userName.isNotEmpty ? userName : 'Loading...',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userRole,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    if (userEmail.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        userEmail,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Profile Options
                              Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildProfileOption(
                                      icon: Icons.person_outline,
                                      title: 'Personal Information',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const PersonalInfoScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildProfileOption(
                                      icon: Icons.history,
                                      title: 'Diagnosis History',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const DiagnosisHistoryScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildProfileOption(
                                      icon: Icons.settings_outlined,
                                      title: 'Settings',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const SettingsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildProfileOption(
                                      icon: Icons.lock_outline,
                                      title: 'Change Password',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ChangePasswordScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    _buildProfileOption(
                                      icon: Icons.help_outline,
                                      title: 'Help & About',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const HelpAboutScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Logout Button at bottom
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _showLogoutConfirmation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[700],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
