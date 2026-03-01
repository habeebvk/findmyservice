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
  Map<String, int> _stats = {};
  bool _isLoadingWorkers = false;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadWorkers(), _loadStats()]);
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await _databaseService.getAdminStats();
      setState(() => _stats = stats);
    } catch (e) {
      debugPrint("Error loading stats: $e");
    } finally {
      setState(() => _isLoadingStats = false);
    }
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
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${worker.name} approved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteWorker(UserModel worker) async {
    bool confirm = await showConfirmDialog(
      "Are you sure you want to delete ${worker.name}? This action cannot be undone.",
    );
    if (confirm) {
      if (worker.id == null) return;
      final result = await _databaseService.deleteUser(worker.id!);
      if (result != -1) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${worker.name} deleted successfully!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete ${worker.name}."),
            backgroundColor: Colors.red,
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
          _loadData();
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
                await AuthService().logout();
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
              onRefresh: _loadData,
              color: Colors.orange,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _workers.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildStatsDashboard();
                  }
                  final w = _workers[index - 1];
                  return _buildWorkerListCard(w);
                },
              ),
            ),
    );
  }

  Widget _buildStatsDashboard() {
    if (_isLoadingStats && _stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            "Dashboard Overview",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _stats.entries.map((e) {
              return _buildStatCard(
                e.key,
                e.value.toString(),
                _getStatColor(e.key),
                _getStatIcon(e.key),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            "Worker Management",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withAlpha(40), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatColor(String key) {
    switch (key) {
      case 'Users':
        return Colors.blue;
      case 'Total Workers':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  IconData _getStatIcon(String key) {
    switch (key) {
      case 'Users':
        return Icons.people;
      case 'Total Workers':
        return Icons.engineering;
      case 'Approved':
        return Icons.check_circle;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Taxi':
      case 'Goods Taxi':
        return Icons.local_taxi;
      case 'Plumber':
        return Icons.plumbing;
      case 'Electrician':
        return Icons.electrical_services;
      case 'Carpenter':
        return Icons.construction;
      default:
        return Icons.category;
    }
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
                  backgroundImage:
                      w.profilePic != null && w.profilePic!.isNotEmpty
                      ? NetworkImage(w.profilePic!)
                      : null,
                  child: w.profilePic == null || w.profilePic!.isEmpty
                      ? const Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
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
                _buildRatingFlag(w),
                if (w.isApproved == 0)
                  IconButton(
                    onPressed: () => _approveWorker(w),
                    icon: Icon(Icons.check_circle, color: Colors.green),
                    tooltip: "Approve Worker",
                  ),
                IconButton(
                  onPressed: () => _deleteWorker(w),
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Delete Worker",
                ),
              ],
            ),
            SizedBox(height: 10),
            RowUI("Work Type", w.workType ?? "Not Specified"),
            RowUI("Experience", w.experience ?? "N/A"),
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

  Widget _buildRatingFlag(UserModel w) {
    return FutureBuilder<double?>(
      future: _databaseService.getWorkerAverageRating(
        workerName: w.name,
        role: w.workType ?? (w.role == 'Goods Taxi' ? 'taxi' : null),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final rating = snapshot.data;
        if (rating == null) {
          return const Text(
            "No reviews",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          );
        }

        final bool isRedFlag = rating <= 2.0;
        return Tooltip(
          message: "Avg Rating: ${rating.toStringAsFixed(1)}",
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isRedFlag
                  ? Colors.red.withAlpha(40)
                  : Colors.green.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isRedFlag ? Colors.red : Colors.green,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flag,
                  size: 14,
                  color: isRedFlag ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  isRedFlag ? "Red Flag" : "Green Flag",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isRedFlag ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
