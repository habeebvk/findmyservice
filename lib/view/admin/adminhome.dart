import 'package:findmyservicesapp/model/user_model.dart';
import 'package:findmyservicesapp/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:findmyservicesapp/services/auth_service.dart';
import 'package:findmyservicesapp/view/auth/login_screen.dart';

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
      final workers = await _databaseService.getWorkersByRole('Worker');
      setState(() => _workers = workers);
    } catch (e) {
      debugPrint("Error loading workers: $e");
    } finally {
      setState(() => _isLoadingWorkers = false);
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

  void _showAddWorkerDialog() {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _locationController = TextEditingController();
    final _salaryController = TextEditingController();
    final _locationFocusNode = FocusNode();
    String? _selectedWorkType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            "Add New Worker",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, "Name", Icons.person),
                SizedBox(height: 10),
                _buildTextField(
                  _emailController,
                  "Email",
                  Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedWorkType,
                  items:
                      [
                            "Plumber",
                            "Electrician",
                            "Carpenter",
                            "Painter",
                            "Welder",
                            "Cleaner",
                            "Mechanic",
                            "Pest Care",
                            "Glass Repair",
                            "Gardening",
                            "Goods Taxi",
                          ]
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                  onChanged: (val) =>
                      setDialogState(() => _selectedWorkType = val),
                  decoration: _inputDecoration("Work Type", Icons.work),
                ),
                SizedBox(height: 10),
                _buildTextField(
                  _phoneController,
                  "Phone Number",
                  Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                GooglePlaceAutoCompleteTextField(
                  textEditingController: _locationController,
                  focusNode: _locationFocusNode,
                  googleAPIKey:
                      "AIzaSyCnXk2YpbWjr5UgTFFflUgfDsagIqwwObE", // Replace with actual key
                  inputDecoration: _inputDecoration(
                    "Location",
                    Icons.location_on,
                  ),
                  debounceTime: 800,
                  countries: ["in"], // Example: India
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    _locationController.text = prediction.description ?? "";
                  },
                  itemClick: (Prediction prediction) {
                    _locationController.text = prediction.description ?? "";
                    _locationController.selection = TextSelection.fromPosition(
                      TextPosition(offset: prediction.description?.length ?? 0),
                    );
                    // Unfocus and refocus to fix cursor position
                    _locationFocusNode.unfocus();
                    Future.delayed(Duration(milliseconds: 100), () {
                      _locationFocusNode.requestFocus();
                    });
                  },
                ),
                SizedBox(height: 10),
                _buildTextField(
                  _salaryController,
                  "Salary (per hour)",
                  Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _selectedWorkType == null ||
                    _phoneController.text.isEmpty ||
                    _locationController.text.isEmpty ||
                    _salaryController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")),
                  );
                  return;
                }

                // Check if email already exists
                final exists = await DatabaseService().userExists(
                  _emailController.text.trim().toLowerCase(),
                );
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Email already registered"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final newUser = UserModel(
                  name: _nameController.text,
                  email: _emailController.text.trim().toLowerCase(),
                  password: _phoneController.text.trim(), // Phone as password
                  role: _selectedWorkType == "Goods Taxi"
                      ? "Goods Taxi"
                      : "Worker",
                  workType: _selectedWorkType,
                  phone: _phoneController.text,
                  location: _locationController.text,
                  salary: _salaryController.text,
                );

                final result = await DatabaseService().insertUser(newUser);
                if (result != -1) {
                  Navigator.pop(context);
                  _loadWorkers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Worker added successfully!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text("SAVE", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Dispose controllers and focus node when dialog is closed
      _nameController.dispose();
      _emailController.dispose();
      _phoneController.dispose();
      _locationController.dispose();
      _salaryController.dispose();
      _locationFocusNode.dispose();
    });
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkerDialog,
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
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
                    ],
                  ),
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
