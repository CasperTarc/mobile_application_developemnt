// lib/delivery_job.dart (Corrected version - FIXES THE ERROR)

class DeliveryJob {
  final String id;
  final String mechanicName;
  final String address;
  final String status;

  // Add 'const' here
  const DeliveryJob({
    required this.id,
    required this.mechanicName,
    required this.address,
    required this.status,
  });
}