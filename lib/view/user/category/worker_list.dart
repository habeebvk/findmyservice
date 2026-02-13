import 'package:findmyservicesapp/model/user_model.dart';
import 'package:findmyservicesapp/services/database_service.dart';
import 'package:findmyservicesapp/view/user/category/workers_details_page.dart';
import 'package:flutter/material.dart';

class ServiceList extends StatefulWidget {
  final String? role;
  const ServiceList({super.key, this.role});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  List<UserModel> workers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkers();
  }

  Future<void> _fetchWorkers() async {
    try {
      final dbWorkers = await DatabaseService().getWorkersByRole(
        widget.role ?? "",
      );
      setState(() {
        workers = dbWorkers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching workers: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        title: Text(
          widget.role ?? 'Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : workers.isEmpty
          ? Center(child: Text("No workers available for this category"))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            _getIconForRole(worker.workType ?? ""),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                worker.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                worker.workType ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      worker.location ?? "N/A",
                                      style: TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    worker.phone ?? "N/A",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${worker.salary ?? "0"}/hr',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServiceDetailPage(
                                      workerName: worker.name,
                                      serviceName: widget.role ?? 'Service',
                                      role: worker.workType ?? 'worker',
                                      price:
                                          int.tryParse(worker.salary ?? '0') ??
                                          0,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Book',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  IconData _getIconForRole(String role) {
    String lower = role.toLowerCase();
    if (lower.contains("electrician")) return Icons.electrical_services;
    if (lower.contains("plumber")) return Icons.plumbing;
    if (lower.contains("carpenter")) return Icons.handyman;
    if (lower.contains("painter")) return Icons.format_paint;
    if (lower.contains("cleaner")) return Icons.cleaning_services;
    if (lower.contains("mechanic")) return Icons.settings;
    if (lower.contains("welder")) return Icons.handyman;
    if (lower.contains("pest")) return Icons.bug_report;
    if (lower.contains("garden")) return Icons.grass;
    if (lower.contains("glass")) return Icons.window;
    return Icons.work;
  }
}
