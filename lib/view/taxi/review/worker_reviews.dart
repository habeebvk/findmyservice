import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';

// Review Model
class Review {
  final int id;
  final String customerName;
  final int rating;
  final String title;
  final String comment;
  final DateTime date;
  final bool verified;
  bool responded;
  String? response;
  final int helpful;

  Review({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.title,
    required this.comment,
    required this.date,
    required this.verified,
    this.responded = false,
    this.response,
    required this.helpful,
  });
}

class ReviewManagementPage extends StatefulWidget {
  @override
  _ReviewManagementPageState createState() => _ReviewManagementPageState();
}

class _ReviewManagementPageState extends State<ReviewManagementPage> {
  List<Review> reviews = [];
  List<Review> filteredReviews = [];
  TextEditingController searchController = TextEditingController();
  String filterRating = 'all';
  String sortBy = 'newest';
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = true;
  Map<int, TextEditingController> responseControllers = {};

  @override
  void initState() {
    super.initState();
    _loadReviewsFromDb();
  }

  Future<void> _loadReviewsFromDb() async {
    setState(() => _isLoading = true);
    try {
      final currentWorkerName = AuthService().currentUser?.name;

      // Normalize to lowercase to match saved review format
      final normalizedWorkerName = currentWorkerName?.toLowerCase() ?? '';

      if (normalizedWorkerName.isEmpty) {
        debugPrint("⚠️ Missing worker name");
        setState(() {
          reviews = [];
        });
        return;
      }

      final fetchedReviews = await _databaseService.getReviews(
        workerName: normalizedWorkerName.trim(),
        role: AuthService().currentUser?.workType ?? 'taxi',
      );

      setState(() {
        reviews = fetchedReviews
            .map(
              (r) => Review(
                id: r.id ?? 0,
                customerName: r.customerName,
                rating: r.rating.toInt(),
                title: "Review",
                comment: r.comment,
                date: DateTime.tryParse(r.date) ?? DateTime.now(),
                verified: true,
                helpful: 0,
              ),
            )
            .toList();

        // Initialize response controllers
        for (Review review in reviews) {
          responseControllers[review.id] = TextEditingController();
        }

        _filterReviews();
      });
    } catch (e) {
      debugPrint("Error loading taxi reviews: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterReviews() {
    setState(() {
      filteredReviews = reviews.where((review) {
        // Search filter
        bool matchesSearch =
            searchController.text.isEmpty ||
            review.customerName.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            review.title.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            review.comment.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );

        // Rating filter
        bool matchesRating =
            filterRating == 'all' ||
            review.rating == int.tryParse(filterRating);

        return matchesSearch && matchesRating;
      }).toList();

      // Sort
      filteredReviews.sort((a, b) {
        switch (sortBy) {
          case 'newest':
            return b.date.compareTo(a.date);
          case 'oldest':
            return a.date.compareTo(b.date);
          case 'highest':
            return b.rating.compareTo(a.rating);
          case 'lowest':
            return a.rating.compareTo(b.rating);
          case 'helpful':
            return b.helpful.compareTo(a.helpful);
          default:
            return 0;
        }
      });
    });
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  Widget _buildOverviewStats() {
    double averageRating = reviews.isEmpty
        ? 0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    int responseRate = reviews.isEmpty
        ? 0
        : ((reviews.where((r) => r.responded).length / reviews.length) * 100)
              .round();
    int thisMonth = reviews
        .where(
          (r) =>
              r.date.month == DateTime.now().month &&
              r.date.year == DateTime.now().year,
        )
        .length;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: "Total Reviews",
                  value: reviews.length.toString(),
                  icon: Icons.message,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: "Avg Rating",
                  value: averageRating.toStringAsFixed(1),
                  icon: Icons.star,
                  color: Colors.amber,
                  subtitle: _buildStars(averageRating.round()),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Widget? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (subtitle != null) ...[SizedBox(height: 4), subtitle],
                  ],
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filterRating,
                  decoration: InputDecoration(
                    labelText: 'Rating',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: '5', child: Text('5 ★')),
                    DropdownMenuItem(value: '4', child: Text('4 ★')),
                    DropdownMenuItem(value: '3', child: Text('3 ★')),
                    DropdownMenuItem(value: '2', child: Text('2 ★')),
                    DropdownMenuItem(value: '1', child: Text('1 ★')),
                  ],
                  onChanged: (value) {
                    filterRating = value!;
                    _filterReviews();
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sortBy,
                  decoration: InputDecoration(
                    labelText: 'Sort',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'newest', child: Text('New')),
                    DropdownMenuItem(value: 'oldest', child: Text('Old')),
                    DropdownMenuItem(value: 'highest', child: Text('High')),
                    DropdownMenuItem(value: 'lowest', child: Text('Low')),
                  ],
                  onChanged: (value) {
                    sortBy = value!;
                    _filterReviews();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Text(
                    review.customerName[0],
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review.customerName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (review.verified) ...[
                            SizedBox(width: 4),
                            Icon(Icons.verified, color: Colors.green, size: 16),
                          ],
                        ],
                      ),
                      Text(
                        "${review.date.day}/${review.date.month}/${review.date.year}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStars(review.rating),
                    SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up, size: 12, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          review.helpful.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Review Title
            Text(
              review.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),

            // Review Comment
            Text(
              review.comment,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),

            // Owner Response
            if (review.responded && review.response != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.store, size: 16, color: Colors.blue[700]),
                        SizedBox(width: 4),
                        Text(
                          "Owner Response",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      review.response!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],

            // Response Section
            if (!review.responded) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: responseControllers[review.id],
                      decoration: InputDecoration(
                        hintText: 'Write a response...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _respondToReview(review),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Reply', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _respondToReview(Review review) {
    String responseText = responseControllers[review.id]!.text.trim();
    if (responseText.isNotEmpty) {
      setState(() {
        review.responded = true;
        review.response = responseText;
        responseControllers[review.id]!.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Response sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Customer Reviews',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Overview Stats
          _buildOverviewStats(),

          // Filters and Search
          _buildFiltersAndSearch(),

          SizedBox(height: 16),

          // Results Count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredReviews.length} review${filteredReviews.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Reviews List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.orange))
                : filteredReviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No reviews found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredReviews.length,
                    itemBuilder: (context, index) {
                      return _buildReviewCard(filteredReviews[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    responseControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
