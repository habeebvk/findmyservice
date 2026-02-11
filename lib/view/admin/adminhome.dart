import 'package:flutter/material.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  List<Map<String, dynamic>> pendingWorkers = [
    {
      "id": 1,
      "name": "Arjun Kumar",
      "work": "Electrician",
      "salary": "250",
      "phone": "9876543210",
      "location": "Chennai",
      "license": "TN12345"
    },
    {
      "id": 2,
      "name": "Rahul Sharma",
      "work": "Plumber",
      "salary": "300",
      "phone": "9988776655",
      "location": "Bangalore",
      "license": "KA98765"
    },
  ];

  /// APPROVE CONFIRMATION
  void approveRequest(int id) async {
    bool confirm = await showConfirmDialog("Approve Request?");
    if (!confirm) return;

    setState(() => pendingWorkers.removeWhere((w) => w["id"] == id));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Worker Approved Successfully!")));
  }

  /// REJECT CONFIRMATION
  void rejectRequest(int id) async {
    bool confirm = await showConfirmDialog("Reject Request?");
    if (!confirm) return;

    setState(() => pendingWorkers.removeWhere((w) => w["id"] == id));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Request Rejected")));
  }

  /// POPUP DIALOG FUNCTION
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
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Worker Approval Requests"),
        centerTitle: true,
      ),
      body: pendingWorkers.isEmpty
          ? Center(
              child: Text("No Pending Requests",
                  style: TextStyle(fontSize: 18, color: Colors.black54)),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: pendingWorkers.length,
              itemBuilder: (context, index) {
                var w = pendingWorkers[index];

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
                              child:
                                  Icon(Icons.person, size: 30, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(w["name"],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            )
                          ],
                        ),
                        SizedBox(height: 10),

                        RowUI("Work Type", w["work"]),
                        RowUI("Salary/hr", "₹${w["salary"]}"),
                        RowUI("Phone", w["phone"]),
                        RowUI("Location", w["location"]),
                        RowUI("License", w["license"]),

                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => approveRequest(w["id"]),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: Text("APPROVE"),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => rejectRequest(w["id"]),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: Text("REJECT"),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget RowUI(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text("$title:  ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis))
        ],
      ),
    );
  }
}
