import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class WallpaperUploadScreen extends StatefulWidget {
  @override
  _WallpaperUploadScreenState createState() => _WallpaperUploadScreenState();
}

class _WallpaperUploadScreenState extends State<WallpaperUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  XFile? _image;
  String? _selectedCategory;
  bool _isLoading = false;
  bool _isPremium = false;

  final List<String> _categories = [
    'Nature',
    'Cars',
    'Abstract',
    'Animals',
    'Technology',
    'Others'
  ];

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

      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to upload a wallpaper.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Get Firebase Storage reference for the `new_wallpaper` folder
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('new_wallpapers')
            .child('${DateTime.now().millisecondsSinceEpoch}_${_image!.name}');

        // Upload the image to Firebase Storage
        final uploadTask = storageRef.putFile(File(_image!.path));
        final snapshot = await uploadTask.whenComplete(() {});
        final imageUrl = await snapshot.ref.getDownloadURL();

        // Upload wallpaper details to Realtime Database
        final dbRef = FirebaseDatabase.instance.ref("wallpapers").push();
        await dbRef.set({
          'name': _nameController.text.trim(),
          'keywords': _keywordsController.text.trim().split(','),
          'category': _selectedCategory,
          'imageUrl': imageUrl, // Save the image URL instead of path
          'uploadedBy': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
          'isPremium': _isPremium,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wallpaper uploaded successfully!')),
        );

        // Reset form
        _nameController.clear();
        _keywordsController.clear();
        setState(() {
          _image = null;
          _selectedCategory = null;
          _isPremium = false;
          _isLoading = false;
        });
        Navigator.pop(context); // Close screen on success
      } catch (e) {
        print('Error uploading wallpaper: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload wallpaper. Please try again.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please complete the form and select an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Upload Wallpaper',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black87,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Credit Balance Display
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credits Balance:',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        '10 Credits', // This will be dynamic based on user's actual credits
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 1,
                      ),
                    ),
                    child: _image == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 50, color: Colors.blueAccent),
                                Text('Select an image'),
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Wallpaper Name',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black26,
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
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _keywordsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Enter Keywords (comma-separated)',
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black26,
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter keywords';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Premium Wallpaper?',
                      style: TextStyle(color: Colors.white),
                    ),
                    Switch(
                      value: _isPremium,
                      onChanged: (value) {
                        setState(() {
                          _isPremium = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'Upload Wallpaper',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
