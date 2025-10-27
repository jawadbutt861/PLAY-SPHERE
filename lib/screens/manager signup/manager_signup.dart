import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ManagerSignup extends StatefulWidget {
  const ManagerSignup({super.key});

  @override
  State<ManagerSignup> createState() => _ManagerSignupState();
}

class _ManagerSignupState extends State<ManagerSignup> {
  final formKey = GlobalKey<FormState>();
  bool showPass = true;

  final TextEditingController fullName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController cnic = TextEditingController();
  final TextEditingController mobileNo = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController venueName = TextEditingController();
  final TextEditingController venueLocation = TextEditingController();

  final ImagePicker picker = ImagePicker();
  List<XFile> selectedImages = [];

  Future<void> pickImages() async {
    try {
      final List<XFile> images = await picker.pickMultiImage();

      if (images.isNotEmpty) {
        setState(() {
          selectedImages = images.take(5).toList(); // limit to 5
        });
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF26A69A),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            width: 400,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text(
                    "Manager Sign Up",
                    style: TextStyle(
                      color: Color(0xFF4E342E),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Full Name ---
                  _buildTextField(
                    controller: fullName,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter full name' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Email ---
                  _buildTextField(
                    controller: email,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter email';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- CNIC ---
                  _buildTextField(
                    controller: cnic,
                    label: 'CNIC',
                    icon: Icons.contact_mail,
                    keyboard: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter CNIC';
                      if (v.length != 13) return 'Invalid CNIC';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Mobile No ---
                  _buildTextField(
                    controller: mobileNo,
                    label: 'Mobile No',
                    icon: Icons.phone,
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter mobile number';
                      if (v.length != 11) return 'Invalid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Venue Name ---
                  _buildTextField(
                    controller: venueName,
                    label: 'Venue Name',
                    icon: Icons.business_outlined,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter venue name' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Venue Location ---
                  _buildTextField(
                    controller: venueLocation,
                    label: 'Venue Location',
                    icon: Icons.location_on,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter location' : null,
                  ),
                  const SizedBox(height: 20),

                  // --- Password ---
                  TextFormField(
                    controller: password,
                    obscureText: showPass,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline,color: Color(0xFFFF7043),),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => showPass = !showPass),
                        icon: Icon(showPass
                            ? Icons.visibility_off
                            : Icons.visibility),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFF26A69A), width: 2),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter password';
                      if (v.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // --- Image Picker Section ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Upload Venue Images (max 5):",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...selectedImages.map(
                        (img) => Image.file(
                          File(img.path),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (selectedImages.length < 5)
                        GestureDetector(
                          onTap: pickImages,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_a_photo,
                                color: Colors.black54),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --- Submit Button ---
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        if (selectedImages.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please upload at least 1 image')),
                          );
                          return;
                        }
                        Navigator.pushNamed(context, '/ManagerLogIn');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7043),
                      minimumSize: const Size(220, 50),
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable TextField Widget ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFFFF7043)),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF26A69A), width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
