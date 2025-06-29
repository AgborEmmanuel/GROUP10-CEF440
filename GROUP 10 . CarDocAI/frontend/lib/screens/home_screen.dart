import 'package:flutter/material.dart';
import 'package:cardocai/screens/search_screen.dart';
import 'package:cardocai/screens/profile_screen.dart';
import 'package:cardocai/screens/record_sound_screen.dart';
import 'package:cardocai/screens/scan_dashboard_screen.dart';
import 'package:cardocai/screens/diagnosis_history_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const HomeContent(),
    const RecordSoundScreen(), // Record screen
    const ScanDashboardScreen(), // Scan screen
    const SearchScreen(), // Search/Maintenance screen
    const ProfileScreen(), // Profile screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_outlined),
            activeIcon: Icon(Icons.mic),
            label: 'Record',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Mechanic',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  Future<void> _launchTelegramGroup() async {
    const url = 'https://t.me/+lOE1j3o-u38xM2M0';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        // Try alternative method
        await launchUrlString('tg://join?invite=lOE1j3o-u38xM2M0', mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Name at top
              const Center(
                child: Text(
                  'CarDoc AI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),

              // Community Section
              const Text(
                'Community',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.telegram,
                title: 'Telegram Group',
                description: 'Join our Telegram group for support and discussions.',
                onTap: _launchTelegramGroup,
              ),

              const SizedBox(height: 32),

              // Diagnosis Section
              const Text(
                'Diagnosis',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.camera_alt_outlined,
                title: 'Scan Dashboard Warning Lights',
                description: 'Scan dashboard warning lights for diagnosis.',
                onTap: () {
                  final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                  if (homeState != null) {
                    homeState._onItemTapped(2);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.mic_outlined,
                title: 'Record Engine Sound',
                description: 'Record engine sound for diagnosis.',
                onTap: () {
                  final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                  if (homeState != null) {
                    homeState._onItemTapped(1);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildFeatureCard(
                icon: Icons.history,
                title: 'Diagnosis History',
                description: 'View your past diagnosis reports.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DiagnosisHistoryScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Mechanic Section
              const Text(
                'Mechanic',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatureCard(
                icon: Icons.build_outlined,
                title: 'Book a Mechanic',
                description: 'Book a mechanic for your car repair.',
                onTap: () {
                  // Switch to the mechanic tab
                  final _HomeScreenState? homeState = 
                      context.findAncestorStateOfType<_HomeScreenState>();
                  if (homeState != null) {
                    homeState._onItemTapped(3);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 