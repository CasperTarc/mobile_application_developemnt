// lib/main.dart

// yyq I PUT THIS
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dev_seed.dart';


import 'package:flutter/material.dart';
import 'app_colors.dart'; // Import your colors
import 'bottom_nav_bar.dart'; // Import your nav bar
import 'delivery_job.dart';
import 'delivery_request.dart';
import 'enhanced_delivery_status_screen.dart'; // Enhanced status screen
import 'enhanced_delivery_confirmation_screen.dart'; // Enhanced confirmation
import 'enhanced_part_request_details_screen.dart'; // Enhanced part details
import 'enhanced_driver_profile_screen.dart'; // Enhanced profile
import 'enhanced_job_history_screen.dart'; // Enhanced job history
import 'delivery_schedule_single_page.dart'; // Single page delivery schedule

// yyq I PUT THIS
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // YYQ I PUT THIS, (await seedPartRequestXYZ789(); only run this code first time, then later comment it)
  // RUN ONCE, then remove or comment out.
  // await seedPartRequestXYZ789();

  // Sign in so Firestore rules that require auth will work
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  runApp(const MyApp());
}

/*void main() {
  runApp(const MyApp());
  }
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Management',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      // Apply the new color theme globally
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          background: AppColors.scaffoldBackground,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white, // Color for title and icons
          elevation: 4,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          titleLarge: TextStyle(color: AppColors.textPrimary),
          titleMedium: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      home: const MainScreen(), // The new home screen with the nav bar
    );
  }
}

// This is the new main screen that manages the bottom navigation bar.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      JobListPage(onTabChanged: _onTabTapped),          // Home with tab callback
      const PartRequestPage(),                          // Requests
      DeliveryScheduleSinglePage(),                     // Schedule
      DeliveryStatusUpdateScreen(orderId: 'DEMO-001'),  // Status
      const ProfileTabScreen(),                         // Profile
    ];
  }

  // List of pages to be shown by the BottomNavBar
  // The JobListPage is now the first page in this list.

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body changes based on the selected tab
      body: _pages[_currentIndex],
      // Use your teammate's custom BottomNavBar
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// Enhanced Homepage with dashboard-style layout
class JobListPage extends StatelessWidget {
  final Function(int)? onTabChanged;
  
  const JobListPage({super.key, this.onTabChanged});

  // Mock data for dashboard stats
  static const Map<String, int> _todayStats = {
    'completed': 8,
    'pending': 3,
    'inProgress': 2,
    'total': 13,
  };

  // Mock data for recent deliveries
  static const List<DeliveryJob> _recentJobs = [
    DeliveryJob(id: 'XYZ-789', mechanicName: 'John\'s Auto Repair', address: '123 Main St, Anytown', status: 'Pending'),
    DeliveryJob(id: 'ABC-123', mechanicName: 'Speedy Mechanics', address: '456 Elm St, Otherville', status: 'In Progress'),
    DeliveryJob(id: 'DEF-456', mechanicName: 'Car Care Center', address: '789 Oak Ave, Sometown', status: 'Completed'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Welcome Message
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, color: AppColors.primary),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Driver John',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.notifications_outlined, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Today's Stats Cards
                  Text(
                    'Today\'s Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Completed', _todayStats['completed']!, Colors.green)),
                      SizedBox(width: 8),
                      Expanded(child: _buildStatCard('In Progress', _todayStats['inProgress']!, Colors.orange)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Pending', _todayStats['pending']!, Colors.blue)),
                      SizedBox(width: 8),
                      Expanded(child: _buildStatCard('Total', _todayStats['total']!, AppColors.primary)),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildActionCard(
                        context,
                        'New Delivery',
                        Icons.add_circle_outline,
                        AppColors.primary,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryConfirmationScreen(orderId: 'NEW-001'))),
                      )),
                      SizedBox(width: 12),
                      Expanded(child: _buildActionCard(
                        context,
                        'View Schedule',
                        Icons.schedule,
                        Colors.blue,
                        () => onTabChanged?.call(2), // Navigate to Schedule tab (index 2)
                      )),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildActionCard(
                        context,
                        'Driver Profile',
                        Icons.person_outline,
                        Colors.purple,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
                      )),
                      SizedBox(width: 12),
                      Expanded(child: _buildActionCard(
                        context,
                        'Job History',
                        Icons.history,
                        Colors.brown,
                        () => Navigator.push(context, MaterialPageRoute(builder: (context) => JobHistoryScreen())),
                      )),
                    ],
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Recent Deliveries
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Deliveries',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to full delivery list
                        },
                        child: Text('View All'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
          
          // Recent Deliveries List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final job = _recentJobs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(job.status).withOpacity(0.2),
                        child: Icon(
                          _getStatusIcon(job.status),
                          color: _getStatusColor(job.status),
                        ),
                      ),
                      title: Text(
                        job.mechanicName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${job.address}\nStatus: ${job.status}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeliveryConfirmationScreen(orderId: job.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: _recentJobs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'in progress':
        return Icons.access_time;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }
}

//yyq - Enhanced Part Request Page
class PartRequestPage extends StatelessWidget {
  const PartRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DeliveryRequestScreen(orderId: 'XYZ-789');
  }
}

// A simple placeholder screen for the other tabs.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// Simplified Profile screen with only 4 main features
class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Info Header
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver John Smith',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'ID: DRV-001 • Active',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Main Features
            Text(
              'Main Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            // 1. List of completed deliveries
            Card(
              elevation: 4,
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
                title: const Text(
                  'Completed Deliveries',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('View all completed delivery jobs'),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primary),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CompletedDeliveriesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            
            // 2. Status history
            Card(
              elevation: 4,
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history, color: Colors.blue),
                ),
                title: const Text(
                  'Status History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Track all delivery status changes'),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primary),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StatusHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            
            // 3. Performance summary
            Card(
              elevation: 4,
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.orange),
                ),
                title: const Text(
                  'Performance Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('View performance metrics & analytics'),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primary),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PerformanceSummaryScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            
            // 4. Settings
            Card(
              elevation: 4,
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings, color: Colors.purple),
                ),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('App preferences and configuration'),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primary),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder screens for the 4 main profile features
class CompletedDeliveriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Completed Deliveries')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.2),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
              title: Text('Delivery #DEL-00${index + 1}'),
              subtitle: Text('Completed on July ${25 - index}, 2025\nCustomer: Auto Parts Store ${index + 1}'),
              trailing: Text('✓', style: TextStyle(color: Colors.green, fontSize: 20)),
            ),
          );
        },
      ),
    );
  }
}

class StatusHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> statusHistory = [
      {'status': 'Delivered', 'time': '14:30', 'date': 'July 31, 2025', 'orderId': 'DEL-001'},
      {'status': 'Out for Delivery', 'time': '09:15', 'date': 'July 31, 2025', 'orderId': 'DEL-001'},
      {'status': 'Picked Up', 'time': '08:45', 'date': 'July 31, 2025', 'orderId': 'DEL-001'},
      {'status': 'Assigned', 'time': '08:00', 'date': 'July 31, 2025', 'orderId': 'DEL-001'},
    ];
    
    return Scaffold(
      appBar: AppBar(title: Text('Status History')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: statusHistory.length,
        itemBuilder: (context, index) {
          final item = statusHistory[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Icon(Icons.update, color: AppColors.primary),
              ),
              title: Text(item['status']),
              subtitle: Text('${item['date']} at ${item['time']}\nOrder: ${item['orderId']}'),
              trailing: Icon(Icons.timeline, color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}

class PerformanceSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Performance Summary')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Performance Stats Cards
            Row(
              children: [
                Expanded(child: _buildPerformanceCard('Total Deliveries', '147', Icons.local_shipping, Colors.blue)),
                SizedBox(width: 12),
                Expanded(child: _buildPerformanceCard('On-Time Rate', '94%', Icons.access_time, Colors.green)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPerformanceCard('Avg Rating', '4.8/5', Icons.star, Colors.orange)),
                SizedBox(width: 12),
                Expanded(child: _buildPerformanceCard('This Month', '23', Icons.calendar_today, AppColors.primary)),
              ],
            ),
            SizedBox(height: 24),
            // Performance Chart Placeholder
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Container(
                      height: 200,
                      child: Center(
                        child: Text('Performance Chart\n(Chart visualization would go here)', 
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPerformanceCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.notifications, color: AppColors.primary),
                  title: Text('Notifications'),
                  subtitle: Text('Manage notification preferences'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.location_on, color: AppColors.primary),
                  title: Text('Location Services'),
                  subtitle: Text('Enable GPS tracking'),
                  trailing: Switch(value: true, onChanged: (value) {}),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.dark_mode, color: AppColors.primary),
                  title: Text('Dark Mode'),
                  subtitle: Text('Toggle dark theme'),
                  trailing: Switch(value: false, onChanged: (value) {}),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.help, color: AppColors.primary),
                  title: Text('Help & Support'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info, color: AppColors.primary),
                  title: Text('About'),
                  trailing: Icon(Icons.arrow_forward_ios),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
