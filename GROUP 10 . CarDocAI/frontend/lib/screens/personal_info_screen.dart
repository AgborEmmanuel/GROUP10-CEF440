import 'package:flutter/material.dart';
import 'package:cardocai/services/supabase_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Load real user data from Supabase
  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      print('🔄 Loading user data for: ${user.id}');

      // Fetch user data with profile
      final response = await client
          .from('users')
          .select('''
            *,
            user_profiles (*)
          ''')
          .eq('user_id', user.id)
          .single();

      print('📊 User data response: $response');

      if (mounted) {
        final userData = response;
        final profileList = userData['user_profiles'] as List?;
        final profileData = profileList?.isNotEmpty == true 
            ? profileList!.first as Map<String, dynamic>
            : null;

        // Populate form fields with real data
        _emailController.text = userData['email'] ?? '';
        
        if (profileData != null) {
          final firstName = profileData['first_name'] ?? '';
          final lastName = profileData['last_name'] ?? '';
          _nameController.text = '$firstName $lastName'.trim();
          _phoneController.text = profileData['phone'] ?? '';
          
          print('✅ Loaded profile data: $firstName $lastName, ${profileData['phone']}');
        } else {
          print('⚠️ No profile data found, will create new profile on save');
          // Set default name from email if no profile exists
          _nameController.text = userData['email']?.split('@').first ?? '';
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final client = SupabaseService.instance.client;
        final user = client.auth.currentUser;

        if (user == null) {
          throw Exception('User not logged in');
        }

        print('🔄 Saving changes for user: ${user.id}');

        // Split name into first and last name
        final nameParts = _nameController.text.trim().split(' ');
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        print('📝 Saving: $firstName | $lastName | ${_phoneController.text}');

        // Use upsert to either update existing profile or create new one
        final profileData = {
          'user_id': user.id,
          'first_name': firstName,
          'last_name': lastName,
          'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Check if profile exists first
        final existingProfile = await client
            .from('user_profiles')
            .select('profile_id')
            .eq('user_id', user.id)
            .maybeSingle();

        if (existingProfile == null) {
          // Create new profile
          profileData['created_at'] = DateTime.now().toIso8601String();
          profileData['preferred_language'] = 'en';
          profileData['location_sharing_enabled'] = 'false';
          profileData['notification_preferences'] = '{"email_notifications": true, "push_notifications": true, "maintenance_reminders": true}';
        }

        await client
            .from('user_profiles')
            .upsert(profileData);

        print('✅ Profile saved successfully');

        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Personal information updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        print('❌ Error saving changes: $e');
        if (mounted) {
          setState(() {
            _isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to update information: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading personal information...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Email shouldn't be editable here
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          // Phone is optional, so no validation required
                          return null;
                        },
                      ),
                      _buildTextField(
                        label: 'Address (Optional)',
                        controller: _addressController,
                        maxLines: 2,
                        validator: (value) {
                          // Address is optional
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.blue.withOpacity(0.6),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 18,
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
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              fillColor: enabled ? null : Colors.grey[50],
              filled: !enabled,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
