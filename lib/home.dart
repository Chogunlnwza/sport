import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plume/booking_history_page.dart';
import 'package:plume/login.dart';
import 'package:plume/venue_detail.dart';
import 'package:plume/booking_page.dart';
import 'package:shimmer/shimmer.dart';
import 'news_page.dart';
import 'profile_page.dart';
import 'UpcomingBookingsPage.dart';
import 'SettingsPage.dart';
import 'ContactUsPage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String searchQuery = '';

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.sports_soccer, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text('Plume Sport', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('News & Updates'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Booking History'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingHistoryPage())),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage())),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Contact Us'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactUsPage())),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Banner Area
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find your perfect",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  "Sports Venue",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search venues (e.g. Football, Badminton)',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              "Popular Venues",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sports_fields').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoading();
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text('Oops! Error loading data.', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                        Text(snapshot.error.toString(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sports_tennis, color: Colors.grey[300], size: 80),
                        const SizedBox(height: 16),
                        const Text('No venues available yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                var fields = snapshot.data!.docs.where((doc) {
                  String name = (doc['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (fields.isEmpty) {
                  return const Center(child: Text('No matching venues found.', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    var field = fields[index];
                    final imageUrl = field['image_url'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VenueDetailPage(fieldId: field.id),
                            ),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: 120,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 120,
                                        height: 110,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 110,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.sports, color: Colors.grey, size: 40),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      field['name'] ?? '',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            field['location'] ?? 'Unknown location',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Available",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Center(child: Icon(Icons.chevron_right, color: Colors.grey)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
