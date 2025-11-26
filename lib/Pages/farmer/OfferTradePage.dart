import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/TradeModels.dart';
import '../../services/TradeService.dart';

// --- Page: Detail View of Item to Trade For ---
class OfferTradePage extends StatelessWidget {
  final TradeListing listing;

  const OfferTradePage({required this.listing});

  @override
  Widget build(BuildContext context) {
    ImageProvider getImageProvider() {
      if (listing.image.startsWith('assets/')) return AssetImage(listing.image);
      if (listing.image.isNotEmpty) return FileImage(File(listing.image));
      return AssetImage('assets/images/default_cover_photo.png');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Offer a Trade", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Image
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F4A2C), Color(0xFFC3E956)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: getImageProvider(),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Item Details
              Text(
                listing.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                listing.quantity,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),

              // --- NEW DESCRIPTION SECTION ---
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Product Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  listing.description.isNotEmpty
                      ? listing.description
                      : "No description provided.",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              // -------------------------------
              Divider(height: 40),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Preferred Trades",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: listing.preferredTrades
                      .map(
                        (t) => Chip(
                          label: Text(t),
                          backgroundColor: Color(0xFFE8F5E9),
                        ),
                      )
                      .toList(),
                ),
              ),

              SizedBox(height: 40),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TradeRequestPage(listing: listing),
                      ),
                    );
                  },
                  child: Text('Offer a Trade'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC3E956),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 50),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Page: Form to Submit an Offer ---
class TradeRequestPage extends StatefulWidget {
  final TradeListing listing;

  TradeRequestPage({required this.listing});

  @override
  _TradeRequestPageState createState() => _TradeRequestPageState();
}

class _TradeRequestPageState extends State<TradeRequestPage> {
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final TradeService _tradeService = TradeService();

  bool _isLoading = false;
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _pickedImage = pickedFile);
  }

  Future<void> _submitOffer() async {
    if (_itemNameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      // Handle non-logged in state (or mock user)
      String uid = user?.uid ?? 'anon_user';
      String uName = user?.displayName ?? 'Anonymous';

      final offer = TradeOfferRequest(
        listingId: widget.listing.id,
        offeredByUid: uid,
        offeredByName: uName,
        itemName: _itemNameController.text,
        itemQuantity: _quantityController.text,
        imagePath: _pickedImage?.path ?? '',
      );

      await _tradeService.submitOffer(offer);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Trade Offer Sent!')));
      Navigator.pop(context); // Close Form
      Navigator.pop(
        context,
      ); // Close Detail Page (Optional, depends on flow preference)
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Make an Offer', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Trading for: ${widget.listing.name}",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),

            Text(
              'Your Item Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _itemNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Apples',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 16),

            Text(
              'Your Item Quantity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                hintText: 'e.g. 1 kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 16),

            Text('Add Image', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _pickedImage == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            Text(
                              "Tap to upload photo",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOffer,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Text('Submit Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC3E956),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
