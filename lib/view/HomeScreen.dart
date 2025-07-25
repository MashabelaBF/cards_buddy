import 'package:card_buddy/view/ScanScreen.dart';
import 'package:card_buddy/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box('cards');
  int? _openIndex;

  void _showAddCardDialog(BuildContext context, {String? scannedCode}) {
    final nameController = TextEditingController();
    final codeController = TextEditingController(text: scannedCode ?? '');
    final nameFocusNode = FocusNode();
    XFile? pickedImage;
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
            // Focus on name field if scannedCode is provided
            if (scannedCode != null) {
              Future.delayed(Duration(milliseconds: 100), () {
                nameFocusNode.requestFocus();
              });
            }
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
                                'Add Card',
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
                              focusNode: nameFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Card Name',
                                prefixIcon: Icon(Icons.title),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              autofocus: scannedCode != null,
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
                                  child: Text('Add'),
                                  onPressed: () {
                                    final name = nameController.text.trim();
                                    final code = codeController.text.trim();
                                    final imagePath = pickedImage?.path;
                                    if (name.isNotEmpty && code.isNotEmpty) {
                                      box.add({
                                        'name': name,
                                        'code': code,
                                        'date': DateTime.now().toString().split(' ')[0],
                                        'image': imagePath,
                                      });
                                      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _openIndex == null,
      onPopInvoked: (didPop) {
        if (!didPop && _openIndex != null) {
          setState(() {
            _openIndex = null;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 32,
                height: 32,
              ),
              SizedBox(width: 12),
              Text('My Reward Cards'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(box: box)));
              },
            ),
          ],
        ),
        body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (_, Box box, __) {
            if (box.isEmpty) return Center(child: Text('No cards yet.'));
            if (_openIndex != null) {
              // Only show the open card, centered vertically
              final key = box.keyAt(_openIndex!);
              final card = box.get(key);
              return Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 0),
                    child: FlippableCard(
                      card: card,
                      isFlipped: true,
                      onTap: () {
                        setState(() {
                          _openIndex = null;
                        });
                      },
                      onDelete: () {
                        box.delete(key);
                        setState(() {
                          _openIndex = null;
                        });
                      },
                    ),
                  ),
                ),
              );
            } else {
              // Show all cards
              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (_, i) {
                  final key = box.keyAt(i);
                  final card = box.get(key);
                  return FlippableCard(
                    card: card,
                    isFlipped: false,
                    onTap: () {
                      setState(() {
                        _openIndex = i;
                      });
                    },
                    onDelete: () {
                      box.delete(key);
                      setState(() {
                        _openIndex = null;
                      });
                    },
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'manualAdd',
              tooltip: 'Add Card Manually',
              onPressed: _openIndex != null ? null : () => _showAddCardDialog(context),
              backgroundColor: _openIndex != null ? Colors.grey[400] : null,
              child: Icon(Icons.add),
            ),
            SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'scanAdd',
              tooltip: 'Scan Card',
              onPressed: _openIndex != null
                  ? null
                  : () async {
                      final scannedCode = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(builder: (_) => ScanScreen()),
                      );
                      if (mounted) {
                        _showAddCardDialog(
                          context,
                          scannedCode: (scannedCode != null && scannedCode.isNotEmpty) ? scannedCode : null,
                        );
                      }
                    },
              backgroundColor: _openIndex != null ? Colors.grey[400] : null,
              child: Icon(Icons.qr_code_scanner),
            ),
          ],
        ),
      ),
    );
  }
}

class FlippableCard extends StatelessWidget {
  final Map card;
  final bool isFlipped;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool forceDeleteIcon;
  final VoidCallback? onEdit; // <-- add this line

  const FlippableCard({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onTap,
    required this.onDelete,
    this.forceDeleteIcon = false,
    this.onEdit, // <-- add this line
  });

  @override
  Widget build(BuildContext context) {
    final String? imagePath = card['image'];
    Widget? cardImageWidget;
    Widget? cardImageWideWidget;
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      cardImageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
      cardImageWideWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imagePath),
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        ),
      );
    }
    final gradient = LinearGradient(
      colors: [
        Colors.grey.shade300,
        Colors.grey.shade100.withOpacity(0.0)
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final borderShadow = [
      BoxShadow(
        color: Colors.grey.withOpacity(0.25),
        blurRadius: 16,
        spreadRadius: 2,
        offset: Offset(0, 4),
      ),
    ];
    if (isFlipped) {
      // Flipped: not clickable except close/delete
      return AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: borderShadow,
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationYTransition(turns: anim, child: child),
          child: Padding(
            key: ValueKey('back'),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Edit button (only used in settings page)
                    if (onEdit != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: onEdit,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        card['name'] ?? '',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center, // <-- center name
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        icon: (forceDeleteIcon || !isFlipped)
                            ? Icon(Icons.delete, color: Colors.red)
                            : Icon(Icons.close, color: Colors.red),
                        onPressed: (forceDeleteIcon || !isFlipped) ? onDelete : onTap,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Saved on: ${card['date']}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                if (cardImageWideWidget != null) ...[
                  SizedBox(height: 18),
                  cardImageWideWidget,
                ],
                SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: card['code'] ?? '',
                    width: double.infinity,
                    height: 70,
                    drawText: false,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      card['code'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, letterSpacing: 2, color: Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Not flipped: clickable
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: borderShadow,
          ),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => RotationYTransition(turns: anim, child: child),
            child: Container(
              key: ValueKey('front'),
              height: 120,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  if (cardImageWidget != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: cardImageWidget,
                    ),
                    SizedBox(width: 24),
                  ],
                  Expanded(
                    child: Text(
                      card['name'] ?? '',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      overflow: TextOverflow.ellipsis,
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
}


class RotationYTransition extends AnimatedWidget {
  final Widget child;
  const RotationYTransition({super.key, required Animation<double> turns, required this.child}) : super(listenable: turns);

  @override
  Widget build(BuildContext context) {
    final Animation<double> turns = listenable as Animation<double>;
    final double angle = turns.value * 3.1415926535897932;
    final bool isBack = turns.value >= 0.5;
    return Transform(
      transform: Matrix4.rotationY(angle),
      alignment: Alignment.center,
      child: isBack
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.1415926535897932),
              child: child,
            )
          : child,
    );
  }
}
