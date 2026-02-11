import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../model/review_model.dart';
// import 'package:intl/intl.dart';

// Assume BookingRequest and BookingStatus are defined here

class ReviewsPage extends StatefulWidget {
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<ReviewModel> reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentWorkerName = AuthService().currentUser?.name;
      final workType = AuthService().currentUser?.workType;

      // Normalize to lowercase to match saved review format
      final normalizedWorkerName = currentWorkerName?.toLowerCase() ?? '';

      debugPrint("🔍 Loading reviews for worker: $normalizedWorkerName");
      debugPrint("🔍 Worker type/role: $workType");

      if (normalizedWorkerName.isEmpty || workType == null) {
        debugPrint("⚠️ Missing worker name or work type");
        setState(() {
          reviews = [];
        });
        return;
      }

      final allReviews = await _databaseService.getReviews(
        workerName: normalizedWorkerName,
        role: workType,
      );

      setState(() {
        reviews = allReviews;
      });
    } catch (e) {
      debugPrint("❌ Error loading reviews: $e");
      debugPrint("Stack trace: ${StackTrace.current}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade400,
        elevation: 0,
        title: Text(
          'Customer Reviews',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,

        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.orange.shade400,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      // FloatingActionButton removed
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade400, Colors.orange.shade200],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: _buildReviewsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    if (_isLoading) {
      debugPrint("🔄 UI: Showing loading indicator");
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (reviews.isEmpty) {
      debugPrint("📭 UI: Showing 'No reviews' message");
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 20),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Customer reviews will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    debugPrint("📋 UI: Building ListView with ${reviews.length} reviews");
    return Column(
      children: [
        // Review count header removed
        // Reviews list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              debugPrint("🎨 UI: Building review card #$index");
              return _buildReviewCard(reviews[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.orange.shade200, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    review.customerName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 5),
                          Text(
                            '${review.rating}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            // Comment
            Text(
              review.comment,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            SizedBox(height: 10),
            // Date
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Text(
                  review.date, // Display stored date string
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
