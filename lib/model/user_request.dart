class UserRequest {
  final int? id;
  final String service;
  final String workerName;
  final String customerName;
  final String requestDate;
  final String status;
  final int price;
  final String description;
  final String paymentStatus;
  final String? transactionId;

  UserRequest({
    this.id,
    required this.service,
    required this.workerName,
    required this.customerName,
    required this.requestDate,
    required this.status,
    required this.price,
    required this.description,
    this.paymentStatus = 'unpaid',
    this.transactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service': service,
      'workerName': workerName,
      'customerName': customerName,
      'requestDate': requestDate,
      'status': status,
      'price': price,
      'description': description,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,
    };
  }

  factory UserRequest.fromMap(Map<String, dynamic> map) {
    return UserRequest(
      id: map['id'],
      service: map['service'],
      workerName: map['workerName'],
      customerName: map['customerName'] ?? 'Customer',
      requestDate: map['requestDate'],
      status: map['status'],
      price: map['price'],
      description: map['description'],
      paymentStatus: map['paymentStatus'] ?? 'unpaid',
      transactionId: map['transactionId'],
    );
  }
}
