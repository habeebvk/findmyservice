import 'package:findmyservicesapp/model/user_model.dart';
import 'package:findmyservicesapp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:findmyservicesapp/services/auth_service.dart';
import 'package:findmyservicesapp/view/auth/login_screen.dart';
import 'package:findmyservicesapp/view/admin/add_worker_dialog.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<UserModel> _workers = [];
  bool _isLoadingWorkers = false;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() => _isLoadingWorkers = true);
    try {
      // Fetch both approved and pending workers
      final workers = await _databaseService.getWorkersByRole(
        'Worker',
        onlyApproved: false,
      );
      setState(() => _workers = workers);
    } catch (e) {
      debugPrint("Error loading workers: $e");
    } finally {
      setState(() => _isLoadingWorkers = false);
    }
  }

  Future<void> _approveWorker(UserModel worker) async {
    bool confirm = await showConfirmDialog(
      "Approve ${worker.name} as a ${worker.role}?",
    );
    if (confirm) {
      if (worker.id == null) return;
      final result = await _databaseService.updateUserApprovalStatus(
        worker.id!,
        1,
      );
      if (result != -1) {
        _loadWorkers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${worker.name} approved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<bool> showConfirmDialog(String message) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirmation"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("CANCEL"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("CONFIRM", style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showAddWorkerDialog() async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => const AddWorkerDialog(),
    );

    // Handle results safely after the dialog is fully closed and Navigator is stable
    if (!mounted) return;

    if (result == "success") {
      // Small delay to allow Navigator transition to finish smoothly
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _loadWorkers();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Worker added successfully!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Manage Workers"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              bool confirm = await showConfirmDialog("Log out of Admin Panel?");
              if (confirm) {
                AuthService().logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: Icon(Icons.logout, color: Colors.orange),
          ),
        ],
      ),
      body: _isLoadingWorkers
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : _workers.isEmpty
          ? Center(
              child: Text(
                "No Workers Added Yet",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadWorkers,
              color: Colors.orange,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _workers.length,
                itemBuilder: (context, index) {
                  final w = _workers[index];
                  return _buildWorkerListCard(w);
                },
              ),
            ),
    );
  }

  Widget _buildWorkerListCard(UserModel w) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.orange.shade300,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        w.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        w.email,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: w.isApproved == 1
                              ? Colors.green.withAlpha(40)
                              : Colors.orange.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          w.isApproved == 1 ? "Approved" : "Pending",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: w.isApproved == 1
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (w.isApproved == 0)
                  IconButton(
                    onPressed: () => _approveWorker(w),
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Approve Worker",
                  ),
              ],
            ),
            SizedBox(height: 10),
            RowUI("Work Type", w.workType ?? "Not Specified"),
            RowUI("Salary/hr", "₹${w.salary ?? '0'}"),
            RowUI("Phone", w.phone ?? "N/A"),
            RowUI("Location", w.location ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget RowUI(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$title:  ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
