class ReviewModel {
  final int? id;
  final String workerName;
  final String customerName;
  final double rating;
  final String comment;
  final String date;

  ReviewModel({
    this.id,
    required this.workerName,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workerName': workerName,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'],
      workerName: map['workerName'],
      customerName: map['customerName'],
      rating: map['rating'].toDouble(),
      comment: map['comment'],
      date: map['date'],
    );
  }
}
