import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/database_service.dart';
import '../../../services/auth_service.dart';
import '../../../model/user_request.dart';
import '../../../model/review_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  List<UserRequest> serviceHistory = [];
  List<UserRequest> taxiHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allBookings = await _databaseService.getBookings();
      setState(() {
        serviceHistory = allBookings
            .where(
              (r) =>
                  r.service.toLowerCase() != 'taxi booking' &&
                  r.status.toLowerCase() == 'accepted',
            )
            .toList();
        taxiHistory = allBookings
            .where(
              (r) =>
                  r.service.toLowerCase() == 'taxi booking' &&
                  (r.status.toLowerCase() == 'accepted' ||
                      r.status.toLowerCase() == 'pending'),
            )
            .toList();
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openReviewSheet(BuildContext context, UserRequest item) {
    final String service = item.service;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final TextEditingController reviewController = TextEditingController();
        double rating = 0;
        File? selectedImage;

        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add Review for $service",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 32,
                          color: Colors.orange,
                        ),
                        onPressed: () => setState(() => rating = index + 1),
                      ),
                    ),
                  ),

                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      labelText: "Write your review",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 15),

                  // Image Upload
                  TextButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setState(() => selectedImage = File(pickedFile.path));
                      }
                    },
                    icon: const Icon(Icons.image, color: Colors.orange),
                    label: const Text(
                      "Upload Image",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),

                  if (selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          selectedImage!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () async {
                      if (rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a rating"),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      try {
                        final authService = AuthService();
                        final dbService = DatabaseService();

                        debugPrint("🔍 Starting review submission...");
                        debugPrint("📝 Service: $service");
                        debugPrint("👤 Worker: ${item.workerName}");
                        debugPrint("⭐ Rating: $rating");

                        // Extract role from service name
                        String serviceLower = service.toLowerCase().trim();
                        String role = 'main';
                        if (serviceLower.contains('taxi') ||
                            serviceLower.contains('goods')) {
                          role = 'taxi';
                        } else if (serviceLower.contains('plumb')) {
                          role = 'plumber';
                        } else if (serviceLower.contains('electri')) {
                          role = 'electrician';
                        } else if (serviceLower.contains('carpen')) {
                          role = 'carpenter';
                        } else if (serviceLower.contains('paint')) {
                          role = 'painter';
                        } else if (serviceLower.contains('clean')) {
                          role = 'cleaner';
                        } else if (serviceLower.contains('pest')) {
                          role = 'pest_care';
                        } else if (serviceLower.contains('glass')) {
                          role = 'glass_repair';
                        } else if (serviceLower.contains('garden')) {
                          role = 'gardening';
                        } else if (serviceLower.contains('mechanic')) {
                          role = 'mechanic';
                        } else if (serviceLower.contains('weld')) {
                          role = 'welder';
                        }

                        debugPrint("🗂️ Extracted role: $role");

                        // Normalize worker name to lowercase and trim any whitespace
                        String normalizedWorkerName = item.workerName
                            .trim()
                            .toLowerCase();
                        debugPrint(
                          "👤 Normalized worker name: $normalizedWorkerName",
                        );

                        final newReview = ReviewModel(
                          workerName: normalizedWorkerName,
                          customerName:
                              authService.currentUser?.name ?? "Guest User",
                          rating: rating,
                          comment: reviewController.text.trim().isEmpty
                              ? "No comment provided"
                              : reviewController.text.trim(),
                          date: DateTime.now().toString().split('.')[0],
                        );

                        debugPrint(
                          "💾 Attempting to save review to database...",
                        );
                        debugPrint("   Worker: ${newReview.workerName}");
                        debugPrint("   Customer: ${newReview.customerName}");
                        debugPrint("   Role: $role");

                        await dbService.insertReview(newReview, role: role);

                        debugPrint("✅ Review saved successfully!");

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Review Submitted Successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("❌ ERROR submitting review: $e");
                        debugPrint("Stack trace: ${StackTrace.current}");

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error submitting review: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Submit Review",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.miscellaneous_services), text: "Services"),
            Tab(icon: Icon(Icons.local_taxi), text: "Taxi"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryList(serviceHistory),
                _buildHistoryList(taxiHistory),
              ],
            ),
    );
  }

  Widget _buildHistoryList(List<UserRequest> dataList) {
    if (dataList.isEmpty) {
      return const Center(child: Text("No requests found"));
    }
    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.orange, size: 30),
            title: Text(item.service),
            subtitle: Text("${item.workerName} • ${item.requestDate}"),
            trailing: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${item.price}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openReviewSheet(context, item),
                    child: const Text(
                      "Add Review",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
