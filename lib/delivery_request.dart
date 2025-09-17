// yyq
class DeliveryRequest {
  final String id;
  final String destination;
  final String dueDateFormatted;
  final String from;
  final String status;
  final List<PartItem> parts;

  DeliveryRequest({
    required this.id,
    required this.destination,
    required this.dueDateFormatted,
    required this.from,
    required this.status,
    required this.parts,
  });
}

class PartItem {
  final String name;
  final String number;
  final int requestedQty;
  final int availableQty;
  final String? note;
  final String? imageUrl;

  PartItem({
    required this.name,
    required this.number,
    required this.requestedQty,
    required this.availableQty,
    this.note,
    this.imageUrl,
  });
}