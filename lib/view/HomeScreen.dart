import 'package:card_buddy/view/ScanScreen.dart';
import 'package:card_buddy/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = Hive.box('cards');
  int? _openIndex;

  void _showAddCardDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _codeController = TextEditingController();
    XFile? _pickedImage;
    void _pickImage(StateSetter setState) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 24, right: 24, bottom: 0),
                      child: Row(
                        children: [
                          Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary, size: 28),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Add Card Manually',
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
                          GestureDetector(
                            onTap: () => _pickImage(setState),
                            child: _pickedImage == null
                                ? Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey[300]!, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, size: 32, color: Colors.grey[500]),
                                          SizedBox(height: 6),
                                          Text('Add Image', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      File(_pickedImage!.path),
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          SizedBox(height: 18),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Card Name',
                              prefixIcon: Icon(Icons.title),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            autofocus: true,
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _codeController,
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
                                  final name = _nameController.text.trim();
                                  final code = _codeController.text.trim();
                                  final imagePath = _pickedImage?.path;
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reward Cards'),
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
            child: Icon(Icons.add),
            backgroundColor: _openIndex != null ? Colors.grey[400] : null,
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'scanAdd',
            tooltip: 'Scan Card',
            child: Icon(Icons.qr_code_scanner),
            onPressed: _openIndex != null ? null : () {
              Navigator.push(context,
                MaterialPageRoute(builder: (_) => ScanScreen()));
            },
            backgroundColor: _openIndex != null ? Colors.grey[400] : null,
          ),
        ],
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
  const FlippableCard({Key? key, required this.card, required this.isFlipped, required this.onTap, required this.onDelete, this.forceDeleteIcon = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? imagePath = card['image'];
    Widget? cardImageWidget;
    Widget? cardImageWideWidget;
    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      cardImageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagePath),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
      cardImageWideWidget = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(imagePath),
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        ),
      );
    }
    if (isFlipped) {
      // Flipped: not clickable except close/delete
      return AnimatedContainer(
        duration: Duration(milliseconds: 250),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => RotationYTransition(turns: anim, child: child),
          child: Padding(
            key: ValueKey('back'),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cardImageWideWidget != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 160,
                      child: cardImageWideWidget,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        card['name'] ?? '',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
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
                SizedBox(height: 10),
                Text('Saved on: ${card['date']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: card['code'] ?? '',
                    width: double.infinity,
                    height: 70,
                    drawText: false,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => RotationYTransition(turns: anim, child: child),
            child: Container(
              key: ValueKey('front'),
              height: 110,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  if (cardImageWidget != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: cardImageWidget,
                    ),
                    SizedBox(width: 20),
                  ],
                  Expanded(
                    child: Text(
                      card['name'] ?? '',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
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
  const RotationYTransition({required Animation<double> turns, required this.child}) : super(listenable: turns);

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
