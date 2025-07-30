import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Card'),
      content: Text('Are you sure you want to delete this card? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

/// Shows a dialog for adding or editing a card.
/// Returns a map with 'name', 'code', and 'image' (String path) if saved, or null if cancelled.
Future<Map<String, dynamic>?> showCardInputDialog({
  required BuildContext context,
  required String title,
  String? initialName,
  String? initialCode,
  XFile? initialImage,
  required bool isPickingImage,
  required Future<XFile?> Function(ImageSource source) pickImage,
  required Future<XFile?> Function(XFile image) cropImage,
}) {
  final nameController = TextEditingController(text: initialName ?? '');
  final codeController = TextEditingController(text: initialCode ?? '');
  XFile? pickedImage = initialImage;

  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 0,
              right: 0,
              top: 0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            width: 32,
                            height: 32,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
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
                                            onPressed: isPickingImage
                                                ? null
                                                : () async {
                                                    final img = await pickImage(ImageSource.gallery);
                                                    if (img != null) setState(() => pickedImage = img);
                                                  },
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
                                            onPressed: isPickingImage
                                                ? null
                                                : () async {
                                                    final img = await pickImage(ImageSource.camera);
                                                    if (img != null) setState(() => pickedImage = img);
                                                  },
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
                                                  leading: Icon(Icons.crop),
                                                  title: Text('Crop Image'),
                                                  onTap: () async {
                                                    final cropped = await cropImage(pickedImage!);
                                                    if (cropped != null) setState(() => pickedImage = cropped);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: Icon(Icons.photo_library),
                                                  title: Text('Change from Gallery'),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    final img = await pickImage(ImageSource.gallery);
                                                    if (img != null) setState(() => pickedImage = img);
                                                  },
                                                ),
                                                ListTile(
                                                  leading: Icon(Icons.photo_camera),
                                                  title: Text('Change from Camera'),
                                                  onTap: () async {
                                                    Navigator.pop(context);
                                                    final img = await pickImage(ImageSource.camera);
                                                    if (img != null) setState(() => pickedImage = img);
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
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8),
                        child: Row(
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
                                  Navigator.pop(context, {
                                    'name': name,
                                    'code': code,
                                    'image': imagePath,
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
