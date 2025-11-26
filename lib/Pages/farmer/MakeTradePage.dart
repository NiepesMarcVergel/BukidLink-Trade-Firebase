import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/TradeService.dart';
import '../../models/TradeModels.dart';

class MakeTradePage extends StatefulWidget {
  // Update 1: Accept listing for Edit Mode
  final TradeListing? listing;

  const MakeTradePage({Key? key, this.listing}) : super(key: key);

  @override
  _MakeTradePageState createState() => _MakeTradePageState();
}

class _MakeTradePageState extends State<MakeTradePage> {
  final TradeService _tradeService = TradeService();
  File? _image;
  final picker = ImagePicker();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descController = TextEditingController(); // Description Controller
  final _prefController = TextEditingController();

  List<String> _preferredTrades = [];
  bool _isLoading = false;
  bool _isEditing = false; // Update 2: State flag

  @override
  void initState() {
    super.initState();
    // Update 3: Check if editing and populate fields
    if (widget.listing != null) {
      _isEditing = true;
      _nameController.text = widget.listing!.name;
      _quantityController.text = widget.listing!.quantity;
      _descController.text = widget.listing!.description;
      _preferredTrades = List.from(widget.listing!.preferredTrades);
      // Image handling logic is done in the build method
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  void _addPref() {
    if (_prefController.text.isNotEmpty) {
      setState(() {
        _preferredTrades.add(_prefController.text.trim());
        _prefController.clear();
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fill in required fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Update 4: Determine Image Path (New file ?? Existing listing image ?? Empty)
      String imagePath = _image?.path ?? (widget.listing?.image ?? '');

      final listingData = TradeListing(
        id: _isEditing ? widget.listing!.id : '', // Use existing ID if editing
        name: _nameController.text,
        quantity: _quantityController.text,
        description: _descController.text,
        preferredTrades: _preferredTrades,
        image: imagePath,
        // Update 5: Preserve farmerId if editing, let service handle if new
        farmerId: _isEditing ? widget.listing!.farmerId : '',
        offersCount: _isEditing ? widget.listing!.offersCount : 0,
        createdAt: _isEditing ? widget.listing!.createdAt : DateTime.now(),
      );

      // Update 6: Call Update or Create based on mode
      if (_isEditing) {
        await _tradeService.updateListing(listingData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Trade Updated!')));
      } else {
        await _tradeService.createListing(listingData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Trade Posted!')));
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update 7: Display Logic for Image (New File > Existing Asset/File > Placeholder)
    ImageProvider? displayImage;
    if (_image != null) {
      displayImage = FileImage(_image!);
    } else if (_isEditing && widget.listing!.image.isNotEmpty) {
      if (widget.listing!.image.startsWith('assets/')) {
        displayImage = AssetImage(widget.listing!.image);
      } else {
        displayImage = FileImage(File(widget.listing!.image));
      }
    }

    return Scaffold(
      appBar: AppBar(
        // Update 8: Dynamic Title
        title: Text(
          _isEditing ? "Edit Trade" : "Make a Trade",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // --- NEW DESCRIPTION FIELD ---
            TextField(
              controller: _descController,
              maxLines: 3, // Allows multiple lines for details
              decoration: InputDecoration(
                labelText: 'Product Details / Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // -----------------------------
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: displayImage == null
                    ? Icon(Icons.add_a_photo)
                    : Image(image: displayImage, fit: BoxFit.cover),
              ),
            ),
            if (_isEditing && displayImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    "Tap image to change",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),

            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _prefController,
                    decoration: InputDecoration(
                      hintText: 'Add preferred item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _addPref,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _preferredTrades
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      onDeleted: () =>
                          setState(() => _preferredTrades.remove(t)),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        _isEditing ? 'Update Trade' : 'Post Trade',
                      ), // Update 9: Dynamic Text
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC3E956),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
