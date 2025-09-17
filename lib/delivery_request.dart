import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_colors.dart';

class DeliveryRequestScreen extends StatefulWidget {
  final String orderId;
  const DeliveryRequestScreen({super.key, required this.orderId});

  @override
  State<DeliveryRequestScreen> createState() => _DeliveryRequestScreenState();
}

class _DeliveryRequestScreenState extends State<DeliveryRequestScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --------- tolerant getters for Firestore fields ---------

  int _getInt(Map<String, dynamic> d, List<String> keys, {int def = 0}) {
    for (final k in keys) {
      final v = d[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) continue;
        final maybe = int.tryParse(s);
        if (maybe != null) return maybe;
        final dbl = double.tryParse(s);
        if (dbl != null) return dbl.toInt();
      }
    }
    return def;
  }

  String _getStr(Map<String, dynamic> d, List<String> keys, {String def = ''}) {
    for (final k in keys) {
      final v = d[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return def;
  }

  bool _getBool(Map<String, dynamic> d, List<String> keys, {bool def = false}) {
    for (final k in keys) {
      final v = d[k];
      if (v is bool) return v;
      if (v is String) {
        final s = v.trim().toLowerCase();
        if (s == 'true' || s == 'yes' || s == '1' || s == 'urgent' || s == 'high') return true;
        if (s == 'false' || s == 'no' || s == '0' || s == 'normal' || s == 'low') return false;
      }
    }
    return def;
  }

  bool _isUrgent(Map<String, dynamic> d) {
    if (_getBool(d, ['urgent', 'isUrgent'])) return true;
    final p = _getStr(d, ['priority', 'priorityLevel', 'status']).toLowerCase();
    return p == 'urgent' || p == 'high';
  }

  // Asset fallback for images if Firestore doesn't have imageUrl
  String _resolveImageUrl(Map<String, dynamic> d) {
    // 1) Use whatever the doc already has
    final existing = _getStr(d, ['imageUrl', 'image', 'photoUrl']);
    if (existing.isNotEmpty) return existing;

    // 2) Fallback by part number
    final pn = _getStr(d, ['partNo', 'partNumber']).toUpperCase();
    const byPartNo = {
      'OF-2345': 'assets/premium_oil_filter.png',
      'CB-7788': 'assets/ceramic_brake_pads.png',
      'AF-1234': 'assets/air_filter.png',
      'AF-8811': 'assets/air_filter.png',
    };
    if (byPartNo.containsKey(pn)) return byPartNo[pn]!;

    // 3) Fallback by keywords in name
    final name = _getStr(d, ['name', 'partName']).toLowerCase();
    if (name.contains('oil')) return 'assets/premium_oil_filter.png';
    if (name.contains('brake')) return 'assets/ceramic_brake_pads.png';
    if (name.contains('filter')) return 'assets/air_filter.png';

    return ''; // shows gear icon placeholder
  }

  @override
  Widget build(BuildContext context) {
    final reqDoc =
    FirebaseFirestore.instance.collection('partRequests').doc(widget.orderId);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Part Request Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Parts List'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: reqDoc.snapshots(),
        builder: (context, reqSnap) {
          final req = reqSnap.data?.data() ?? <String, dynamic>{};

          // Header fields: tolerant to your keys (mechanicName, destinationBay, priority)
          final bay = _getStr(req, ['bay', 'bayName', 'destinationBay'], def: 'Bay A-3');
          final tech = _getStr(req, ['technician', 'tech', 'mechanic', 'mechanicName'], def: 'Mike Johnson');
          final urgentFromHeader = _isUrgent(req);

          final linesQuery = reqDoc.collection('lines');

          return Column(
            children: [
              // Header with totals and URGENT detection
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: linesQuery.snapshots(),
                builder: (context, linesSnap) {
                  final lines = linesSnap.data?.docs ?? [];
                  final totalItems = lines.length;
                  final totalQty = lines.fold<int>(
                    0,
                        (sum, d) => sum +
                        _getInt(d.data(), ['requested', 'requestQty', 'qtyRequested', 'requestedQty']),
                  );
                  final anyLineUrgent = lines.any((d) => _isUrgent(d.data()));
                  final urgent = urgentFromHeader || anyLineUrgent;

                  return _buildHeader(
                    orderId: widget.orderId,
                    bay: bay,
                    tech: tech,
                    urgent: urgent,
                    totalItems: totalItems,
                    totalQty: totalQty,
                  );
                },
              ),

              // Tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Parts List
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: linesQuery.snapshots(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = snap.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No parts in this request'));
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final d = docs[i].data();

                            return _PartTile(
                              data: d,
                              name: _getStr(d, ['name', 'partName'], def: 'Unnamed Part'),
                              partNumber: _getStr(d, ['partNo', 'partNumber']),
                              category: _getStr(d, ['category', 'type']),
                              imageUrl: _resolveImageUrl(d),
                              requested: _getInt(d, ['requested', 'requestQty', 'qtyRequested', 'requestedQty']),
                              available: _getInt(d, [
                                'available',
                                'availableQty',
                                'qtyAvailable',
                                'stock',
                                'stockQty',
                                // fallbacks to support older schema
                                'allocated',
                                'allocatedQty',
                                'qtyAllocated',
                              ]),
                              location: _getStr(d, ['location', 'shelf', 'bin', 'shelfLocation'], def: '—'),
                              urgent: _isUrgent(d),
                              description: _getStr(d, ['description', 'desc', 'notes']),
                            );
                          },
                        );
                      },
                    ),

                    // Summary
                    _SummaryView(
                      reqDoc: reqDoc,
                      requestData: req,
                      getInt: _getInt,
                      getStr: _getStr,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader({
    required String orderId,
    required String bay,
    required String tech,
    required bool urgent,
    required int totalItems,
    required int totalQty,
  }) {
    // URGENT colors per your request
    const urgentBg = Color(0xFFE33946); // background #E33946
    const urgentFg = Color(0xFFFDEDB2); // text       #FDEDB2

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Left: Order + Bay/Tech; Right: URGENT badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order $orderId',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$bay - $tech',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (urgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgentBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Color(0xFFE33946), width: 1.5),
                  ),
                  child: const Text(
                    'URGENT',
                    style: TextStyle(
                      color: urgentFg,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Only Total Items + Total Qty
          Row(
            children: [
              Expanded(child: _headerStat('Total Items', '$totalItems')),
              Expanded(child: _headerStat('Total Qty', '$totalQty')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final String name;
  final String partNumber;
  final String category;
  final String imageUrl;
  final int requested;
  final int available; // using Available
  final String location;
  final bool urgent;
  final String description;

  const _PartTile({
    required this.data,
    required this.name,
    required this.partNumber,
    required this.category,
    required this.imageUrl,
    required this.requested,
    required this.available,
    required this.location,
    required this.urgent,
    required this.description,
  });

  Color _categoryColor(String category) {
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

  @override
  Widget build(BuildContext context) {
    // Shortage check: requested > available
    final isShort = requested > available;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: urgent ? Border.all(color: Colors.red.withOpacity(0.3), width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header row (no price, no description)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PartImage(imageUrl: imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (partNumber.isNotEmpty)
                        Text(
                          partNumber,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _categoryColor(category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 11,
                              color: _categoryColor(category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Icons row: Requested | Available | Location (single line)
            Row(
              children: [
                _Info(icon: Icons.shopping_cart, label: 'Requested', value: '$requested'),
                _Info(
                  icon: Icons.inventory_2_outlined,
                  label: 'Available',
                  value: '$available',
                  valueColor: isShort ? Colors.red : AppColors.textPrimary,
                ),
                _Info(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: location.isEmpty ? '—' : location,
                  singleLine: true,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status + Details button
            Row(
              children: [
                Expanded(child: _Availability(isShort: isShort)),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showDetails(context),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('Details'),
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
            // Extra red "short by N" chip removed per your request.
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldBackground,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _DetailsImage(imageUrl: imageUrl),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Part Information', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _detailRow('Part Number:', partNumber.isEmpty ? '—' : partNumber),
                        _detailRow('Category:', category.isEmpty ? '—' : category),
                        _detailRow('Requested:', '$requested'),
                        _detailRow('Available:', '$available'),
                        _detailRow('Location:', location.isEmpty ? '—' : location),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(description, style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
                        ],
                        const SizedBox(height: 16),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _PartImage extends StatelessWidget {
  final String imageUrl;
  const _PartImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _imageWidget(imageUrl),
      ),
    );
  }

  Widget _imageWidget(String url) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.settings, color: AppColors.primary, size: 32),
      );
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(Icons.settings, color: AppColors.primary, size: 32),
      );
    }
    return Icon(Icons.settings, color: AppColors.primary, size: 32);
  }
}

class _DetailsImage extends StatelessWidget {
  final String imageUrl;
  const _DetailsImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imageUrl,
          width: 140,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.settings, color: AppColors.primary, size: 72),
        ),
      );
    }
    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 140,
          height: 140,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.settings, color: AppColors.primary, size: 72),
        ),
      );
    }
    return Icon(Icons.settings, color: AppColors.primary, size: 72);
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool singleLine;

  const _Info({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.singleLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: singleLine ? 1 : null,
            overflow: singleLine ? TextOverflow.ellipsis : TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Availability extends StatelessWidget {
  final bool isShort;
  const _Availability({required this.isShort});

  @override
  Widget build(BuildContext context) {
    final color = isShort ? Colors.red : Colors.green;
    final text = isShort ? 'Not enough stock' : 'In Stock';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isShort ? Icons.warning : Icons.check_circle, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  final DocumentReference<Map<String, dynamic>> reqDoc;
  final Map<String, dynamic> requestData;
  final int Function(Map<String, dynamic>, List<String>, {int def}) getInt;
  final String Function(Map<String, dynamic>, List<String>, {String def}) getStr;

  const _SummaryView({
    required this.reqDoc,
    required this.requestData,
    required this.getInt,
    required this.getStr,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary;

    final specialInstructions = getStr(
      requestData,
      ['specialInstructions', 'notes', 'instructions'],
      def: 'Please handle oil filter with care. Brake pads are urgent. Verify part numbers before delivery.',
    );

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: reqDoc.collection('lines').snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        // Precompute data list and total before building widgets
        final lineDatas = docs.map((d) => d.data()).toList();

        final totalQty = lineDatas.fold<int>(
          0,
              (sum, data) => sum +
              getInt(data, ['requested', 'requestQty', 'qtyRequested', 'requestedQty']),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Order Summary (name + xQty only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.summarize, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    for (final data in lineDatas)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                getStr(data, ['name', 'partName'], def: 'Unnamed Part'),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'x${getInt(data, ['requested', 'requestQty', 'qtyRequested', 'requestedQty'])}',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Quantity:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '$totalQty',
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
              ),
              const SizedBox(height: 16),

              // Delivery Information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_shipping, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _infoRow('Destination:', getStr(requestData, ['destination', 'destinationBay'], def: 'Bay A-3 - Workshop Floor')),
                    _infoRow('Mechanic:', getStr(requestData, ['technician', 'tech', 'mechanic', 'mechanicName'], def: 'Mike Johnson')),
                    _infoRow('Required by:', getStr(requestData, ['requiredBy'], def: '—')),
                    _infoRow('Priority:', _priorityText(requestData), isHighlight: _priorityIsUrgent(requestData)),
                    _infoRow('Address:', getStr(requestData, ['address'], def: '123 Workshop Lane, Auto Center')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Special Instructions (Display only)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.note_alt, color: Colors.orange, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        specialInstructions,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _priorityIsUrgent(Map<String, dynamic> requestData) {
    if (requestData['urgent'] is bool) return requestData['urgent'] == true;
    final s = requestData['priority']?.toString().toLowerCase();
    return s == 'urgent' || s == 'high';
  }

  String _priorityText(Map<String, dynamic> requestData) {
    return _priorityIsUrgent(requestData) ? 'URGENT' : 'Normal';
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
}