import 'package:flutter/material.dart';
import 'app_colors.dart';

class PartDetail {
  final String partName;
  final String partNumber;
  final int requestedQty;
  final int availableQty;
  final double unitPrice;
  final String category;
  final String description;
  final String imageUrl;
  final bool isUrgent;
  final String location;

  PartDetail({
    required this.partName,
    required this.partNumber,
    required this.requestedQty,
    required this.availableQty,
    required this.unitPrice,
    required this.category,
    required this.description,
    required this.imageUrl,
    this.isUrgent = false,
    required this.location,
  });
}

class EnhancedPartRequestDetailsScreen extends StatefulWidget {
  final String orderId;

  const EnhancedPartRequestDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _EnhancedPartRequestDetailsScreenState createState() => _EnhancedPartRequestDetailsScreenState();
}

class _EnhancedPartRequestDetailsScreenState extends State<EnhancedPartRequestDetailsScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  final List<PartDetail> parts = [
    PartDetail(
      partName: 'Premium Oil Filter',
      partNumber: 'OF-2345',
      requestedQty: 2,
      availableQty: 15,
      unitPrice: 24.99,
      category: 'Engine',
      description: 'High-performance oil filter for Honda Civic. Provides superior filtration and protection for your engine. Recommended replacement every 6 months.',
      imageUrl: 'assets/oil_filter.png',
      isUrgent: true,
      location: 'Shelf A-3, Row 2',
    ),
    PartDetail(
      partName: 'Air Filter Element',
      partNumber: 'AF-1234',
      requestedQty: 1,
      availableQty: 8,
      unitPrice: 18.50,
      category: 'Engine',
      description: 'High-flow air filter element that improves engine performance and fuel efficiency.',
      imageUrl: 'assets/air_filter.png',
      location: 'Shelf B-1, Row 3',
    ),
    PartDetail(
      partName: 'Ceramic Brake Pads',
      partNumber: 'BP-5678',
      requestedQty: 3,
      availableQty: 4,
      unitPrice: 89.99,
      category: 'Brakes',
      description: 'Premium ceramic brake pads for superior stopping power and reduced noise.',
      imageUrl: 'assets/brake_pads.png',
      location: 'Shelf C-2, Row 1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Part Request Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(text: 'Parts List'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildOrderHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPartsListTab(),
                _buildSummaryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    //'Order ${widget.orderId}',
                    'Order XYZ-789',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Bay A-3 - Mike Johnson',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Text(
                  'URGENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat('Total Items', '${parts.length}'),
              ),
              Expanded(
                child: _buildHeaderStat('Total Qty', '${parts.fold(0, (sum, part) => sum + part.requestedQty)}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsListTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: parts.length,
      itemBuilder: (context, index) {
        final part = parts[index];
        return _buildPartCard(part, index);
      },
    );
  }

  Widget _buildPartCard(PartDetail part, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: part.isUrgent ? Border.all(color: Colors.red.withOpacity(0.3), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (part.isUrgent)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.priority_high, color: Colors.red, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'URGENT REQUEST',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: part.imageUrl.startsWith('assets/')
                            ? Image.asset(
                                part.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.settings,
                                    color: AppColors.primary,
                                    size: 40,
                                  );
                                },
                              )
                            : Icon(
                                Icons.settings,
                                color: AppColors.primary,
                                size: 40,
                              ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            part.partName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            part.partNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(part.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              part.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getCategoryColor(part.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${part.unitPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'per unit',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  part.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                Divider(height: 1),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPartInfo('Requested', '${part.requestedQty}', Icons.shopping_cart),
                    ),
                    Expanded(
                      child: _buildPartInfo('Available', '${part.availableQty}', Icons.inventory),
                    ),
                    Expanded(
                      child: _buildPartInfo('Location', part.location, Icons.location_on),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildAvailabilityIndicator(part),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showPartDetails(part),
                      icon: Icon(Icons.info_outline, size: 16),
                      label: Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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

  Widget _buildPartInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityIndicator(PartDetail part) {
    bool isAvailable = part.availableQty >= part.requestedQty;
    Color color = isAvailable ? Colors.green : Colors.red;
    String text = isAvailable ? 'In Stock' : 'Partial Stock';
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.warning,
            color: color,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(),
          SizedBox(height: 16),
          _buildDeliveryInfoCard(),
          SizedBox(height: 16),
          _buildNotesCard(),
          SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.summarize,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...parts.map((part) => _buildSummaryItem(part)).toList(),
          Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Quantity:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${parts.fold(0, (sum, part) => sum + part.requestedQty)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(PartDetail part) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              part.partName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'x${part.requestedQty}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // Expanded(
          //   child: Text(
          //     '\$${(part.unitPrice * part.requestedQty).toStringAsFixed(2)}',
          //     textAlign: TextAlign.right,
          //     style: TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.textPrimary,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow('Destination:', 'Bay A-3 - Workshop Floor'),
          _buildInfoRow('Mechanic:', 'Mike Johnson'),
          _buildInfoRow('Required by:', 'Today 2:30 PM'),
          _buildInfoRow('Priority:', 'URGENT', isHighlight: true),
          _buildInfoRow('Address:', '123 Workshop Lane, Auto Center'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isHighlight ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.note_alt,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Special Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Please handle oil filter with care. Brake pads are urgent and needed for immediate repair. Verify part numbers before delivery.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startPicking(),
            icon: Icon(Icons.shopping_cart),
            label: Text('Start Picking Parts'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _callMechanic(),
                icon: Icon(Icons.phone),
                label: Text('Call Mechanic'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _printList(),
                icon: Icon(Icons.print),
                label: Text('Print List'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'engine':
        return Colors.blue;
      case 'brakes':
        return Colors.red;
      case 'electrical':
        return Colors.orange;
      case 'suspension':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  double _calculateTotalValue() {
    return parts.fold(0.0, (sum, part) => sum + (part.unitPrice * part.requestedQty));
  }

  void _showPartDetails(PartDetail part) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        part.partName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.settings,
                              color: AppColors.primary,
                              size: 80,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Part Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildDetailRow('Part Number:', part.partNumber),
                        _buildDetailRow('Category:', part.category),
                        _buildDetailRow('Unit Price:', '\$${part.unitPrice.toStringAsFixed(2)}'),
                        _buildDetailRow('Location:', part.location),
                        SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          part.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startPicking() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting parts picking process...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _callMechanic() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling Mike Johnson...')),
    );
  }

  void _printList() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Printing parts list...')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
