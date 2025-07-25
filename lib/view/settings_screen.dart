import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'HomeScreen.dart';

class SettingsScreen extends StatelessWidget {
  final Box box;
  const SettingsScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    void _showEditCardDialog(BuildContext context, dynamic key, Map card) {
      final nameController = TextEditingController(text: card['name'] ?? '');
      final codeController = TextEditingController(text: card['code'] ?? '');
      XFile? pickedImage = card['image'] != null && card['image'].toString().isNotEmpty
          ? XFile(card['image'])
          : null;
      bool isPickingImage = false;
      void pickImage(StateSetter setState, ImageSource source) async {
        if (isPickingImage) return;
        isPickingImage = true;
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            pickedImage = image;
          });
        }
        isPickingImage = false;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dialogBackgroundColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0, left: 24, right: 24, bottom: 0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                width: 32,
                                height: 32,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Edit Card',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[600]),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 8),
                              pickedImage == null
                                  ? Column(
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.grey[300]!, width: 1.5),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              'assets/logo.png',
                                              width: 40,
                                              height: 40,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey[200],
                                                foregroundColor: Colors.black87,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                              icon: Icon(Icons.photo_library),
                                              label: Text('Gallery'),
                                              onPressed: isPickingImage ? null : () => pickImage(setState, ImageSource.gallery),
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              ),
                                              icon: Icon(Icons.photo_camera),
                                              label: Text('Camera'),
                                              onPressed: isPickingImage ? null : () => pickImage(setState, ImageSource.camera),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                          ),
                                          builder: (context) {
                                            return SafeArea(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    leading: Icon(Icons.photo_library),
                                                    title: Text('Change from Gallery'),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      pickImage(setState, ImageSource.gallery);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons.photo_camera),
                                                    title: Text('Change from Camera'),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      pickImage(setState, ImageSource.camera);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons.delete, color: Colors.red),
                                                    title: Text('Remove Image', style: TextStyle(color: Colors.red)),
                                                    onTap: () {
                                                      setState(() {
                                                        pickedImage = null;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.file(
                                          File(pickedImage!.path),
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                              SizedBox(height: 18),
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Card Name',
                                  prefixIcon: Icon(Icons.title),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  labelText: 'Card Number',
                                  prefixIcon: Icon(Icons.numbers),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                keyboardType: TextInputType.text,
                              ),
                              SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                                    ),
                                    child: Text('Save'),
                                    onPressed: () {
                                      final name = nameController.text.trim();
                                      final code = codeController.text.trim();
                                      final imagePath = pickedImage?.path;
                                      if (name.isNotEmpty && code.isNotEmpty) {
                                        box.put(key, {
                                          'name': name,
                                          'code': code,
                                          'date': card['date'],
                                          'image': imagePath,
                                        });
                                        Navigator.pop(context);
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => SettingsScreen(box: box),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: box.isEmpty
          ? Center(child: Text('No cards yet.'))
          : ListView.builder(
              itemCount: box.length,
              itemBuilder: (_, i) {
                final key = box.keyAt(i);
                final card = box.get(key);
                return FlippableCard(
                  card: card,
                  isFlipped: true,
                  onTap: () {}, // No flip/close on settings
                  onDelete: () {
                    box.delete(key);
                    (context as Element).markNeedsBuild();
                  },
                  forceDeleteIcon: true,
                  onEdit: () {
                    _showEditCardDialog(context, key, card);
                  },
                );
              },
            ),
    );
  }
}
