import 'package:flutter/material.dart';
import 'package:cardocai/screens/mechanic_screen.dart';
import 'package:cardocai/screens/home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedFilter = 'Rating'; // Default filter

  // Sample data for mechanics (in a real app, this would come from a backend)
  final List<Map<String, dynamic>> _mechanics = [
    {
      'name': 'John\'s Auto Repair',
      'rating': 4.9,
      'reviews': 156,
      'distance': 2.5,
      'specialties': ['Engine', 'Transmission', 'Brakes'],
      'image': 'assets/images/default_avatar.png',
    },
    {
      'name': 'Elite Car Service',
      'rating': 4.8,
      'reviews': 142,
      'distance': 3.1,
      'specialties': ['Diagnostics', 'Electrical', 'AC'],
      'image': 'assets/images/default_avatar.png',
    },
    {
      'name': 'Pro Auto Care',
      'rating': 4.7,
      'reviews': 98,
      'distance': 1.8,
      'specialties': ['Engine', 'Suspension', 'Tune-ups'],
      'image': 'assets/images/default_avatar.png',
    },
    {
      'name': 'Master Mechanics',
      'rating': 4.6,
      'reviews': 78,
      'distance': 4.2,
      'specialties': ['Brakes', 'Steering', 'Diagnostics'],
      'image': 'assets/images/default_avatar.png',
    },
  ];

  List<Map<String, dynamic>> get filteredMechanics {
    var mechanics = List<Map<String, dynamic>>.from(_mechanics);
    
    // Apply search filter if text is entered
    if (_searchController.text.isNotEmpty) {
      mechanics = mechanics.where((mechanic) {
        final name = mechanic['name'].toString().toLowerCase();
        final specialties = mechanic['specialties'] as List<String>;
        final searchTerm = _searchController.text.toLowerCase();
        
        return name.contains(searchTerm) || 
               specialties.any((specialty) => specialty.toLowerCase().contains(searchTerm));
      }).toList();
    }
    
    // Apply sorting based on selected filter
    switch (_selectedFilter) {
      case 'Rating':
        mechanics.sort((a, b) => b['rating'].compareTo(a['rating']));
        break;
      case 'Nearest':
        mechanics.sort((a, b) => a['distance'].compareTo(b['distance']));
        break;
      case 'Most Reviews':
        mechanics.sort((a, b) => b['reviews'].compareTo(a['reviews']));
        break;
    }
    
    return mechanics;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Mechanic'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find a Mechanic',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for mechanics or services',
                        prefixIcon: const Icon(Icons.search, color: Colors.blue),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _isSearching = false;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isSearching = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Options
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Rating'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Nearest'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Most Reviews'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Results or Default List
            Expanded(
              child: filteredMechanics.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/CarFAULTDiagnosisAPP (2)/SEACRH.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No mechanics found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredMechanics.length,
                      itemBuilder: (context, index) {
                        final mechanic = filteredMechanics[index];
                        return _buildMechanicCard(mechanic);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: isSelected ? Colors.white : Colors.blue,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMechanicCard(Map<String, dynamic> mechanic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MechanicScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(mechanic['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mechanic['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mechanic['rating'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${mechanic['reviews']} reviews)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey[600],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${mechanic['distance']} km away',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: (mechanic['specialties'] as List<String>)
                          .map((specialty) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  specialty,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 