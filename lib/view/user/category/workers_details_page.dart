import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../model/user_request.dart';
import '../../../model/review_model.dart';
import '../../../services/auth_service.dart';

class ServiceDetailPage extends StatefulWidget {
  final String? workerName;
  final String? serviceName;
  final int? price;
  final String? role;

  const ServiceDetailPage({
    super.key,
    this.workerName,
    this.serviceName,
    this.price,
    this.role,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<ReviewModel> reviews = []; // Store reviews from DB
  bool _isLoadingReviews = true;

  bool showReviewBox = false; // Toggle review input container
  TextEditingController reviewController = TextEditingController();
  int rating = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
  setState(() => _isLoadingReviews = true);

  try {
    final rawWorkerName = widget.workerName ?? 'Jimmy Hadson';
    final rawRole = widget.role ?? 'service';

    final normalizedWorkerName = rawWorkerName.trim().toLowerCase();

    final fetchedReviews = await _databaseService.getReviews(
      workerName: normalizedWorkerName,
      role: rawRole,
    );

    setState(() {
      reviews = fetchedReviews;
    });
  } catch (e) {
    debugPrint("Error loading reviews: $e");
  } finally {
    setState(() => _isLoadingReviews = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        title: const Text(
          "Booking Page",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.orange[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  "https://images.unsplash.com/photo-1605810230434-7631ac76ec81",
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card Details
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.serviceName ?? "Expert Carpentry Services",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.workerName ?? "Jimmy Hadson",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.hourglass_bottom,
                        "5+ years",
                        "Experience",
                      ),
                      _buildInfoItem(Icons.star, "4.5", "Rating"),
                      _buildInfoItem(
                        Icons.attach_money,
                        "₹${widget.price ?? 19}",
                        "Per Hour",
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "About",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Jimmy Hadson is a seasoned carpenter with over 5 years hands-on expertise. "
                    "Specialized in custom furniture, home renovations, and detailed woodwork.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Reviews Title + Add Review Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Reviews",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showReviewBox = !showReviewBox;
                      });
                    },
                    child: const Text(
                      "Add Review",
                      style: TextStyle(fontSize: 16, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            // Review Input Container
            if (showReviewBox)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: reviewController,
                      decoration: const InputDecoration(
                        labelText: "Write your review",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),

                    // Rating stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),

                    const SizedBox(height: 10),

                    // Submit Review Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (reviewController.text.isNotEmpty && rating > 0) {
                            try {
                                final newReview = ReviewModel(
                                  workerName: (widget.workerName ?? 'Jimmy Hadson')
                                      .trim()
                                      .toLowerCase(),
                                  customerName: AuthService().currentUser?.name ?? 'Guest User',
                                  rating: rating.toDouble(),
                                  comment: reviewController.text.trim(),
                                  date: DateTime.now().toIso8601String(),
                                );
                                await _databaseService.insertReview(
                                  newReview,
                                  role: widget.role ?? 'service',
                                );

                              await _loadReviews();

                              setState(() {
                                reviewController.clear();
                                rating = 0;
                                showReviewBox = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Review submitted!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error submitting review: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text(
                          "Submit Review",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Review List
            _isLoadingReviews
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : reviews.isEmpty
                ? const Text(
                    "No reviews yet",
                    style: TextStyle(color: Colors.grey),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.orange,
                        ),
                        title: Text(review.comment),
                        subtitle: Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "by ${review.customerName}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 20),

            // Book Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final databaseService = DatabaseService();
                      final request = UserRequest(
                        service:
                            widget.serviceName ?? "Expert Carpentry Services",
                        workerName: widget.workerName ?? "Jimmy Hadson",
                        customerName:
                            AuthService().currentUser?.name ?? "Guest User",
                        requestDate: DateTime.now().toString().split('.')[0],
                        status: 'pending',
                        price: widget.price ?? 19,
                        description:
                            "Service request for ${widget.serviceName ?? "Expert Carpentry Services"}",
                      );

                      await databaseService.insertBooking(
                        request,
                        role: widget.role,
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Booking request sent successfully!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error booking service: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }
}








