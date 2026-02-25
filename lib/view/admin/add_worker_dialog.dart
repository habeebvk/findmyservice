import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:findmyservicesapp/model/user_model.dart';
import 'package:findmyservicesapp/services/database_service.dart';

class AddWorkerDialog extends StatefulWidget {
  const AddWorkerDialog({super.key});

  @override
  State<AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends State<AddWorkerDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationFocusNode = FocusNode();
  String? _selectedWorkType;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _locationFocusNode.dispose();
    super.dispose();
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Add New Worker",
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nameController, "Name", Icons.person),
            const SizedBox(height: 10),
            _buildTextField(
              _emailController,
              "Email",
              Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
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
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
              onChanged: (val) => setState(() => _selectedWorkType = val),
              decoration: _inputDecoration("Work Type", Icons.work),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              _phoneController,
              "Phone Number",
              Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            GooglePlaceAutoCompleteTextField(
              textEditingController: _locationController,
              focusNode: _locationFocusNode,
              googleAPIKey:
                  "AIzaSyCnXk2YpbWjr5UgTFFflUgfDsagIqwwObE", // Replace with actual key
              inputDecoration: _inputDecoration("Location", Icons.location_on),
              debounceTime: 800,
              countries: const ["in"], // Example: India
              getPlaceDetailWithLatLng: (Prediction prediction) {
                _locationController.text = prediction.description ?? "";
              },
              itemClick: (Prediction prediction) {
                _locationController.text = prediction.description ?? "";
                if (!_locationFocusNode.hasPrimaryFocus) {
                  _locationFocusNode.unfocus();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_locationFocusNode.canRequestFocus) {
                      _locationFocusNode.requestFocus();
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 10),
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
          child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_nameController.text.isEmpty ||
                _emailController.text.isEmpty ||
                _selectedWorkType == null ||
                _phoneController.text.isEmpty ||
                _locationController.text.isEmpty ||
                _salaryController.text.isEmpty) {
              return;
            }

            // Check if email already exists
            final exists = await DatabaseService().userExists(
              _emailController.text.trim().toLowerCase(),
            );
            if (exists) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Email already exists."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }

            final newUser = UserModel(
              name: _nameController.text,
              email: _emailController.text.trim().toLowerCase(),
              password: _phoneController.text.trim(), // Phone as password
              role: _selectedWorkType == "Goods Taxi" ? "Goods Taxi" : "Worker",
              workType: _selectedWorkType,
              phone: _phoneController.text,
              location: _locationController.text,
              salary: _salaryController.text,
            );

            final dbResult = await DatabaseService().insertUser(newUser);

            if (dbResult != -1) {
              if (context.mounted) {
                Navigator.pop(context, "success");
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Failed to add worker. Please try again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("SAVE", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
