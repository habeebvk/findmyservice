import 'package:findmyservicesapp/view/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../model/user_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();

  // Common Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Role selection
  String _selectedRole = "Customer";
  String? _selectedWorkType;
  final _salaryController = TextEditingController();
  final _experienceController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Check if email already exists
        final exists = await _databaseService.userExists(_emailController.text);
        if (exists) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Email already registered")));
          return;
        }

        final newUser = UserModel(
          name: _nameController.text,
          email: _emailController.text.trim().toLowerCase(),
          password: _passwordController.text,
          role: _selectedRole,
          phone: _customerPhoneController.text,
          location: _customerAddressController.text,
          workType: _selectedRole == "Customer" ? null : _selectedWorkType,
          salary: _selectedRole == "Customer" ? null : _salaryController.text,
          experience: _selectedRole == "Customer"
              ? null
              : _experienceController.text,
          description: _selectedRole == "Customer"
              ? null
              : _descriptionController.text,
          isApproved: _selectedRole == "Customer" ? 1 : 0,
        );

        final result = await _databaseService.insertUser(newUser);
        if (result != -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account created successfully!")),
          );
          // Navigate to login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Failed to create account")));
        }
      } catch (e) {
        debugPrint("Registration error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred. Please try again.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please agree to terms and conditions")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.person_add,
                      size: 40,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sign up to get started",
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: 20),

                  // Register form
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                              "Full Name",
                              Icons.person,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "Enter your name"
                                : null,
                          ),
                          SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration("Email", Icons.email),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Enter email";
                              final regex = RegExp(
                                r"^[a-zA-Z]+@[a-zA-Z]+\.[a-zA-Z]+$",
                              );
                              if (!regex.hasMatch(v)) {
                                return "Email must contain only alphabets (e.g. abc@def.com)";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),

                          // Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: _inputDecoration("Password", Icons.lock)
                                .copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                            validator: (v) => v != null && v.length < 6
                                ? "Min 6 characters"
                                : null,
                          ),
                          SizedBox(height: 20),

                          // Confirm Password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            decoration:
                                _inputDecoration(
                                  "Confirm Password",
                                  Icons.lock,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                            validator: (v) => v != _passwordController.text
                                ? "Passwords do not match"
                                : null,
                          ),
                          SizedBox(height: 20),

                          // Role Selection
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: ["Customer", "Worker", "Goods Taxi"]
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedRole = val!;
                                if (_selectedRole == "Goods Taxi") {
                                  _selectedWorkType = "Goods Taxi";
                                } else if (_selectedRole == "Customer") {
                                  _selectedWorkType = null;
                                } else {
                                  _selectedWorkType = null;
                                }
                              });
                            },
                            decoration: _inputDecoration("Role", Icons.people),
                          ),
                          SizedBox(height: 20),

                          if (_selectedRole != "Customer") ...[
                            // Provider specific fields
                            if (_selectedRole == "Worker") ...[
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
                                        ]
                                        .map(
                                          (type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedWorkType = val),
                                decoration: _inputDecoration(
                                  "Service Type",
                                  Icons.work,
                                ),
                                validator: (v) =>
                                    _selectedRole == "Worker" && v == null
                                    ? "Select service"
                                    : null,
                              ),
                              SizedBox(height: 20),
                            ],
                            TextFormField(
                              controller: _salaryController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                "Wages (per hour)",
                                Icons.currency_rupee,
                              ),
                              validator: (v) =>
                                  _selectedRole != "Customer" &&
                                      (v == null || v.isEmpty)
                                  ? "Enter wages"
                                  : null,
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _experienceController,
                              decoration: _inputDecoration(
                                "Experience (e.g. 5 years)",
                                Icons.history,
                              ),
                              validator: (v) =>
                                  _selectedRole != "Customer" &&
                                      (v == null || v.isEmpty)
                                  ? "Enter experience"
                                  : null,
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: _inputDecoration(
                                "About You / Description",
                                Icons.description,
                              ),
                              validator: (v) =>
                                  _selectedRole != "Customer" &&
                                      (v == null || v.isEmpty)
                                  ? "Enter description"
                                  : null,
                            ),
                            SizedBox(height: 20),
                          ],

                          // Phone & Address
                          TextFormField(
                            controller: _customerPhoneController,
                            decoration: _inputDecoration(
                              "Phone Number",
                              Icons.phone_android,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Enter phone" : null,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _customerAddressController,
                            decoration: _inputDecoration(
                              "Address",
                              Icons.location_on,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Enter address" : null,
                          ),
                          SizedBox(height: 20),

                          // Terms
                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (v) =>
                                    setState(() => _agreeToTerms = v ?? false),
                              ),
                              Expanded(
                                child: Text("I agree to Terms & Conditions"),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "Create Account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // After the Register Button
                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to login screen and remove this page from stack
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
