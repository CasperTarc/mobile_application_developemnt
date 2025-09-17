import 'package:flutter/material.dart';
import 'app_colors.dart';

class DeliveryScheduleSinglePage extends StatefulWidget {
  @override
  _DeliveryScheduleSinglePageState createState() => _DeliveryScheduleSinglePageState();
}

class _DeliveryScheduleSinglePageState extends State<DeliveryScheduleSinglePage> 
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  String selectedDate = 'Today';
  String selectedFilter = 'All';

  final List<DeliveryScheduleItem> todayDeliveries = [
    DeliveryScheduleItem(
      id: 'DEL-001',
      customerName: 'ABC Auto Parts',
      partName: 'Engine Oil Filter',
      address: '123 Main Street, Downtown',
      scheduledTime: '9:00 AM',
      estimatedDuration: '15 min',
      priority: 'High',
      status: 'Pending',
      distance: '5.2 km',
      phone: '+1 (555) 123-4567',
      notes: 'Call before arrival. Fragile items.',
    ),
    DeliveryScheduleItem(
      id: 'DEL-002',
      customerName: 'Quick Fix Garage',
      partName: 'Brake Pads Set',
      address: '456 Oak Avenue, Uptown',
      scheduledTime: '10:30 AM',
      estimatedDuration: '20 min',
      priority: 'Medium',
      status: 'In Progress',
      distance: '8.7 km',
      phone: '+1 (555) 234-5678',
      notes: 'Heavy package. Use service entrance.',
    ),
    DeliveryScheduleItem(
      id: 'DEL-003',
      customerName: 'Metro Service Center',
      partName: 'Spark Plugs (4 pcs)',
      address: '789 Pine Road, Westside',
      scheduledTime: '1:00 PM',
      estimatedDuration: '12 min',
      priority: 'Low',
      status: 'Scheduled',
      distance: '12.3 km',
      phone: '+1 (555) 345-6789',
      notes: 'Standard delivery. No special instructions.',
    ),
    DeliveryScheduleItem(
      id: 'DEL-004',
      customerName: 'City Motors',
      partName: 'Air Filter',
      address: '321 Elm Street, Eastside',
      scheduledTime: '3:15 PM',
      estimatedDuration: '18 min',
      priority: 'High',
      status: 'Scheduled',
      distance: '6.8 km',
      phone: '+1 (555) 456-7890',
      notes: 'Urgent delivery. Customer waiting.',
    ),
    DeliveryScheduleItem(
      id: 'DEL-005',
      customerName: 'Express Auto',
      partName: 'Battery 12V',
      address: '654 Maple Drive, Southside',
      scheduledTime: '4:45 PM',
      estimatedDuration: '25 min',
      priority: 'Medium',
      status: 'Scheduled',
      distance: '15.1 km',
      phone: '+1 (555) 567-8901',
      notes: 'Heavy item. Assistance may be required.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildSummarySection(),
                  _buildFiltersSection(),
                  _buildDeliveryList(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _optimizeRoute(),
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.route, color: Colors.white),
        label: Text(
          'Optimize Route',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Delivery Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 80, 24, 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.today, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Today - ${_getCurrentDate()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '${_getFilteredDeliveries().length} deliveries scheduled',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    List<DeliveryScheduleItem> filtered = _getFilteredDeliveries();
    int completed = filtered.where((d) => d.status == 'Completed').length;
    int inProgress = filtered.where((d) => d.status == 'In Progress').length;
    int pending = filtered.where((d) => d.status == 'Pending').length;
    int scheduled = filtered.where((d) => d.status == 'Scheduled').length;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Today\'s Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Completed',
                  completed.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'In Progress',
                  inProgress.toString(),
                  Colors.blue,
                  Icons.local_shipping,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Pending',
                  pending.toString(),
                  Colors.orange,
                  Icons.pending,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Scheduled',
                  scheduled.toString(),
                  Colors.purple,
                  Icons.schedule,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildProgressBar(completed, inProgress, pending, scheduled),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int completed, int inProgress, int pending, int scheduled) {
    int total = completed + inProgress + pending + scheduled;
    if (total == 0) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Progress',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.withOpacity(0.2),
          ),
          child: Stack(
            children: [
              // Completed section
              FractionallySizedBox(
                widthFactor: completed / total,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.green,
                  ),
                ),
              ),
              // In Progress section
              FractionallySizedBox(
                widthFactor: (completed + inProgress) / total,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.blue],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${((completed + inProgress) / total * 100).toInt()}% Progress',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDate,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  isExpanded: true,
                  items: ['Today', 'Tomorrow', 'This Week']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDate = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFilter,
                  icon: Icon(Icons.filter_list, color: AppColors.primary),
                  isExpanded: true,
                  items: ['All', 'High Priority', 'Pending', 'In Progress', 'Scheduled']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryList() {
    List<DeliveryScheduleItem> filteredDeliveries = _getFilteredDeliveries();
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Text(
            'Delivery Schedule (${filteredDeliveries.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ...filteredDeliveries.map((delivery) => _buildDeliveryCard(delivery)).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryScheduleItem delivery) {
    Color priorityColor = _getPriorityColor(delivery.priority);
    Color statusColor = _getStatusColor(delivery.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with time and priority
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.schedule,
                    color: priorityColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.scheduledTime,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Est. ${delivery.estimatedDuration} • ${delivery.distance}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    delivery.priority,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    border: Border.all(color: statusColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    delivery.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer and part info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            delivery.customerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            delivery.partName,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      delivery.id,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Address
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        delivery.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Phone
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      delivery.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                
                if (delivery.notes.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          delivery.notes,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callCustomer(delivery.phone),
                        icon: Icon(Icons.phone, size: 16),
                        label: Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToLocation(delivery.address),
                        icon: Icon(Icons.navigation, size: 16),
                        label: Text('Navigate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _startDelivery(delivery),
                        icon: Icon(Icons.play_arrow, size: 16),
                        label: Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Scheduled':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  List<DeliveryScheduleItem> _getFilteredDeliveries() {
    List<DeliveryScheduleItem> filtered = List.from(todayDeliveries);
    
    if (selectedFilter != 'All') {
      if (selectedFilter == 'High Priority') {
        filtered = filtered.where((d) => d.priority == 'High').toList();
      } else {
        filtered = filtered.where((d) => d.status == selectedFilter).toList();
      }
    }
    
    // Sort by scheduled time
    filtered.sort((a, b) => _parseTime(a.scheduledTime).compareTo(_parseTime(b.scheduledTime)));
    
    return filtered;
  }

  DateTime _parseTime(String timeStr) {
    // Simple time parsing for sorting
    final parts = timeStr.split(' ');
    final time = parts[0].split(':');
    int hour = int.parse(time[0]);
    int minute = int.parse(time[1]);
    
    if (parts[1] == 'PM' && hour != 12) {
      hour += 12;
    } else if (parts[1] == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return DateTime(2024, 1, 1, hour, minute);
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  void _callCustomer(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $phone...')),
    );
  }

  void _navigateToLocation(String address) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening navigation to $address...')),
    );
  }

  void _startDelivery(DeliveryScheduleItem delivery) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting delivery ${delivery.id}...')),
    );
  }

  void _optimizeRoute() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Optimizing delivery route...')),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}

class DeliveryScheduleItem {
  final String id;
  final String customerName;
  final String partName;
  final String address;
  final String scheduledTime;
  final String estimatedDuration;
  final String priority;
  final String status;
  final String distance;
  final String phone;
  final String notes;

  DeliveryScheduleItem({
    required this.id,
    required this.customerName,
    required this.partName,
    required this.address,
    required this.scheduledTime,
    required this.estimatedDuration,
    required this.priority,
    required this.status,
    required this.distance,
    required this.phone,
    required this.notes,
  });
}
