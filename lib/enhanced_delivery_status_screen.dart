import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'enhanced_delivery_confirmation_screen.dart';

enum DeliveryStatus {
  assigned,
  pickedUp,
  enRoute,
  arrived,
  delivered,
  failed,
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.enRoute:
        return 'En Route';
      case DeliveryStatus.arrived:
        return 'Arrived';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case DeliveryStatus.assigned:
        return Colors.grey;
      case DeliveryStatus.pickedUp:
        return Colors.blue;
      case DeliveryStatus.enRoute:
        return Colors.orange;
      case DeliveryStatus.arrived:
        return Colors.purple;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.failed:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case DeliveryStatus.assigned:
        return Icons.assignment;
      case DeliveryStatus.pickedUp:
        return Icons.inventory;
      case DeliveryStatus.enRoute:
        return Icons.local_shipping;
      case DeliveryStatus.arrived:
        return Icons.location_on;
      case DeliveryStatus.delivered:
        return Icons.check_circle;
      case DeliveryStatus.failed:
        return Icons.error;
    }
  }
}

class DeliveryStatusUpdateScreen extends StatefulWidget {
  final String orderId;
  final DeliveryStatus currentStatus;

  const DeliveryStatusUpdateScreen({
    Key? key,
    required this.orderId,
    this.currentStatus = DeliveryStatus.assigned,
  }) : super(key: key);

  @override
  _DeliveryStatusUpdateScreenState createState() => _DeliveryStatusUpdateScreenState();
}

class _DeliveryStatusUpdateScreenState extends State<DeliveryStatusUpdateScreen>
    with TickerProviderStateMixin {
  late DeliveryStatus currentStatus;
  final TextEditingController _notesController = TextEditingController();
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  final List<DeliveryStatus> statusFlow = [
    DeliveryStatus.assigned,
    DeliveryStatus.pickedUp,
    DeliveryStatus.enRoute,
    DeliveryStatus.arrived,
    DeliveryStatus.delivered,
  ];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.currentStatus;
    _progressController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgressValue(),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
  }

  double _getProgressValue() {
    int currentIndex = statusFlow.indexOf(currentStatus);
    return (currentIndex + 1) / statusFlow.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Update Delivery Status'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProgressHeader(),
            _buildOrderInfo(),
            _buildStatusTimeline(),
            _buildQuickActions(),
            _buildNotesSection(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Order ${widget.orderId}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  currentStatus.icon,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  currentStatus.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            '${(_getProgressValue() * 100).toInt()}% Complete',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Destination', 'Bay A-3 - Mike Johnson'),
            _buildInfoRow(Icons.place, 'Address', '123 Workshop Lane, Auto Center'),
            _buildInfoRow(Icons.schedule, 'Due Time', '2:30 PM Today'),
            _buildInfoRow(Icons.inventory, 'Items', '3 Parts (Oil Filter, Brake Pads, etc.)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 20),
            ...statusFlow.asMap().entries.map((entry) {
              int index = entry.key;
              DeliveryStatus status = entry.value;
              bool isCompleted = statusFlow.indexOf(currentStatus) >= index;
              bool isCurrent = status == currentStatus;
              
              return _buildTimelineItem(
                status,
                isCompleted,
                isCurrent,
                index < statusFlow.length - 1,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    DeliveryStatus status,
    bool isCompleted,
    bool isCurrent,
    bool hasNextItem,
  ) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted ? status.color : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: isCurrent
                    ? Border.all(color: status.color, width: 3)
                    : null,
              ),
              child: Icon(
                status.icon,
                color: isCompleted ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            if (hasNextItem)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? status.color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: hasNextItem ? 40 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCompleted ? AppColors.textPrimary : Colors.grey,
                  ),
                ),
                if (isCompleted && !isCurrent)
                  Text(
                    _getStatusTime(status),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (isCurrent)
                  Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: status.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusTime(DeliveryStatus status) {
    // Mock times - in real app, these would come from your data
    switch (status) {
      case DeliveryStatus.assigned:
        return '09:00 AM';
      case DeliveryStatus.pickedUp:
        return '10:30 AM';
      case DeliveryStatus.enRoute:
        return '11:15 AM';
      case DeliveryStatus.arrived:
        return '12:45 PM';
      case DeliveryStatus.delivered:
        return '01:20 PM';
      default:
        return '';
    }
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Call Mechanic',
                  Icons.phone,
                  Colors.blue,
                  () => _callMechanic(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Navigate',
                  Icons.navigation,
                  AppColors.primary,
                  () => _navigate(),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Take Photo',
                  Icons.camera_alt,
                  Colors.purple,
                  () => _takePhoto(),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  'Report Issue',
                  Icons.report_problem,
                  Colors.orange,
                  () => _reportIssue(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any updates or notes about this delivery...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.scaffoldBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          if (_canAdvanceStatus())
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _advanceStatus(),
                icon: Icon(_getNextStatus().icon),
                label: Text('Mark as ${_getNextStatus().displayName}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getNextStatus().color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_canAdvanceStatus()) SizedBox(height: 12),
          if (currentStatus == DeliveryStatus.arrived)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startDeliveryConfirmation(),
                icon: Icon(Icons.verified),
                label: Text('Start Delivery Confirmation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _canAdvanceStatus() {
    int currentIndex = statusFlow.indexOf(currentStatus);
    return currentIndex < statusFlow.length - 1 && currentStatus != DeliveryStatus.delivered;
  }

  DeliveryStatus _getNextStatus() {
    int currentIndex = statusFlow.indexOf(currentStatus);
    return statusFlow[currentIndex + 1];
  }

  void _advanceStatus() {
    if (_canAdvanceStatus()) {
      setState(() {
        currentStatus = _getNextStatus();
        _progressAnimation = Tween<double>(
          begin: _progressAnimation.value,
          end: _getProgressValue(),
        ).animate(CurvedAnimation(
          parent: _progressController,
          curve: Curves.easeInOut,
        ));
        _progressController.reset();
        _progressController.forward();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${currentStatus.displayName}'),
          backgroundColor: currentStatus.color,
        ),
      );
    }
  }

  void _startDeliveryConfirmation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryConfirmationScreen(orderId: widget.orderId),
      ),
    );
  }

  void _callMechanic() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling mechanic...')),
    );
  }

  void _navigate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening navigation...')),
    );
  }

  void _takePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Camera opened...')),
    );
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Issue'),
          content: Text('What issue would you like to report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Issue reported successfully')),
                );
              },
              child: Text('Report'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}
