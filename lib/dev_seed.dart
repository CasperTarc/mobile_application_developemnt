import 'package:cloud_firestore/cloud_firestore.dart';

/// Seeds a clean part request at partRequests/XYZ-789.
/// - Deletes the existing document and its `lines` subcollection first.
/// - Creates a header document and three line documents with asset images and descriptions.
/// Run ONCE, verify, then remove or comment out the call.
Future<void> seedPartRequestXYZ789() async {
  const orderId = 'XYZ-789';
  final db = FirebaseFirestore.instance;
  final doc = db.collection('partRequests').doc(orderId);

  // 1) Remove existing request and its lines (start from scratch)
  try {
    final lines = await doc.collection('lines').get();
    for (final d in lines.docs) {
      await d.reference.delete();
    }
    await doc.delete();
  } catch (_) {
    // ignore if it doesn't exist yet
  }

  // 2) Create header (keys match your schema)
  await doc.set({
    'destinationBay': 'Bay A-3',
    'mechanicName': 'Mike Johnson',
    'priority': 'URGENT', // or set 'urgent': true if you prefer boolean
    'address': '123 Workshop Lane, Auto Center',
    'specialInstructions': 'Brake pads are urgent. Verify part numbers before delivery.',
  });

  // 3) Create lines (Requested = requestedQty, Available = allocatedQty)
  final lines = [
    {
      'id': 'OF-2345',
      'name': 'Premium Oil Filter',
      'partNumber': 'OF-2345',
      'partNo': 'OF-2345',
      'category': 'Engine',
      'requestedQty': 1,
      'allocatedQty': 5,
      'location': 'Shelf A-1, Row 2',
      'imageUrl': 'assets/premium_oil_filter.png',
      'description': 'High-efficiency oil filter for extended engine protection.',
    },
    {
      'id': 'CB-7788',
      'name': 'Ceramic Brake Pads',
      'partNumber': 'CB-7788',
      'partNo': 'CB-7788',
      'category': 'Brakes',
      'requestedQty': 3,
      'allocatedQty': 2,
      'location': 'Shelf C-2, Row 5',
      'imageUrl': 'assets/ceramic_brake_pads.png',
      'description': 'Low-dust ceramic pads for quiet, consistent braking performance.',
    },
    {
      'id': 'AF-1234',
      'name': 'Air Filter Element',
      'partNumber': 'AF-1234',
      'partNo': 'AF-1234',
      'category': 'Engine',
      'requestedQty': 2,
      'allocatedQty': 2,
      'location': 'Shelf B-1, Row 3',
      'imageUrl': 'assets/air_filter.png',
      'description': 'High-flow filter element that traps dust to protect intake.',
    },
  ];

  for (final l in lines) {
    final id = l['id'] as String;
    final data = Map<String, dynamic>.from(l)..remove('id');
    await doc.collection('lines').doc(id).set(data);
  }
}

/// Optional helper to ONLY add/update descriptions (no deletions).
/// Call once if you already have data and just want to merge descriptions.
Future<void> addDescriptionsOnlyXYZ789() async {
  final doc = FirebaseFirestore.instance.collection('partRequests').doc('XYZ-789');
  await doc.collection('lines').doc('OF-2345').set({
    'description': 'High-efficiency oil filter for extended engine protection.',
  }, SetOptions(merge: true));

  await doc.collection('lines').doc('CB-7788').set({
    'description': 'Low-dust ceramic pads for quiet, consistent braking performance.',
  }, SetOptions(merge: true));

  await doc.collection('lines').doc('AF-1234').set({
    'description': 'High-flow filter element that traps dust to protect intake.',
  }, SetOptions(merge: true));
}