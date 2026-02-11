class Job {
  final int? id;
  final String title;
  final String category;
  final String description;
  final int price;
  final String providerName;
  final String date;

  Job({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.providerName,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'price': price,
      'providerName': providerName,
      'date': date,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      description: map['description'],
      price: map['price'],
      providerName: map['providerName'],
      date: map['date'],
    );
  }
}
