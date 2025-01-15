import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

class WallpaperUploadForm extends StatefulWidget {
  @override
  _WallpaperUploadFormState createState() => _WallpaperUploadFormState();
}

class _WallpaperUploadFormState extends State<WallpaperUploadForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  XFile? _image;
  bool _isLoading = false;

  // Firebase references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage =
        await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      setState(() {
        _isLoading = true;
      });

      print("Uploading wallpaper...");

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          print("No user logged in");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to upload a wallpaper.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Save wallpaper details to Firebase Realtime Database
        final docRef =
            FirebaseDatabase.instance.ref().child('wallpapers').push();
        await docRef.set({
          'name': _nameController.text.trim(),
          'keywords': _keywordsController.text.trim().split(','),
          'imagePath': _image!.path,
          'uploadedBy': user.uid,
          'uploadedAt': ServerValue.timestamp,
        });

        print("Wallpaper uploaded successfully");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wallpaper uploaded successfully!')),
        );

        // Reset form
        _nameController.clear();
        _keywordsController.clear();
        setState(() {
          _image = null;
          _isLoading = false;
        });
      } catch (e) {
        print("Error uploading wallpaper: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to upload wallpaper. Please try again.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("Form is not valid or image not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please complete the form and select an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Slide-Up Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 1.0,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Center(
                          child: Container(
                            height: 5,
                            width: 50,
                            color: Colors.grey[600],
                            margin: EdgeInsets.only(bottom: 20),
                          ),
                        ),
                        // Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[600]!,
                                width: 2,
                              ),
                            ),
                            child: _image == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            size: 50, color: Colors.white),
                                        SizedBox(height: 8),
                                        Text(
                                          'Tap to select an image',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_image!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Wallpaper Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Wallpaper Name',
                            labelStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.edit, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Keywords Text Area
                        TextFormField(
                          controller: _keywordsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Enter Keywords (comma-separated)',
                            labelStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey[800],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter search keywords';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Upload',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
