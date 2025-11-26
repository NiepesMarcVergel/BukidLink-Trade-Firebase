import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// =========================================================
//  TESTING TOGGLE - testing123
// =========================================================
const bool isTesting = false; // testing123: Change to false to use Firebase

// =========================================================
//  MOCK DATA (Hardcoded for testing)
// =========================================================
final List<Map<String, dynamic>> mockListings = [
  {
    'id': '1',
    'name': 'Sack of Rice (Sinandomeng)',
    'quantity': '2 Sacks',
    'preferred_trades': ['Vegetables', 'Native Chicken'],
    'image': 'assets/images/sample_rice.png', // sample images muna
    'user_id': 'test_user_uid',
    'offers_count': 5,
    'created_at': DateTime.now(),
  },
  {
    'id': '2',
    'name': 'Fresh Tilapia',
    'quantity': '5 Kilos',
    'preferred_trades': ['Fruits', 'Fertilizer'],
    'image': '',
    'user_id': 'other_user',
    'offers_count': 1,
    'created_at': DateTime.now(),
  },
  {
    'id': '3',
    'name': 'Organic Fertilizer',
    'quantity': '10 Bags',
    'preferred_trades': ['Seeds', 'Tools'],
    'image': '',
    'user_id': 'test_user_uid', // Same as "Me" for MyTrades test
    'offers_count': 0,
    'created_at': DateTime.now(),
  },
];

final List<Map<String, dynamic>> mockOffers = [
  {
    'item_name': 'Native Chicken',
    'item_quantity': '3 Heads',
    'offered_by_name': 'Juan Dela Cruz',
    'image_path': '',
    'status': 'pending',
  },
  {
    'item_name': 'String Beans',
    'item_quantity': '5 Bundles',
    'offered_by_name': 'Maria Clara',
    'image_path': '',
    'status': 'pending',
  },
];

// =========================================================
//  MAIN APP CODE
// =========================================================

// Trade Page Main
class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const FarmerAppBar(),

          // Search Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Cards
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MakeTradePage(),
                                ),
                              );
                            },
                            child: TradeCard(
                              title: 'Make a Trade',
                              icon: Icons.add_shopping_cart,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MyTradesPage(),
                                ),
                              );
                            },
                            child: TradeCard(
                              title: 'My Trades',
                              icon: Icons.list_alt,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // LIST BUILDER (Switches between Real and Test)
                    isTesting
                        ? _buildMockList() // testing123
                        : _buildFirestoreList(), // Real Firebase
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FarmerBottomNavBar(currentIndex: 1),
    );
  }

  // --- Widget for Testing Mode ---
  Widget _buildMockList() {
    var docs = mockListings.where((data) {
      String name = data['name'] ?? '';
      return name.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    if (docs.isEmpty) return Center(child: Text("No mock trades found."));

    return Column(
      children: List.generate((docs.length / 2).ceil(), (index) {
        int first = index * 2;
        int second = first + 1;
        var firstData = docs[first];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Expanded(
                child: TradeItemCard(
                  docId: firstData['id'],
                  name: firstData['name'],
                  image: firstData['image'],
                  quantity: firstData['quantity'],
                  preferred:
                      (firstData['preferred_trades'] as List?)?.join(', ') ??
                      'Any',
                ),
              ),
              SizedBox(width: 12),
              if (second < docs.length)
                Expanded(
                  child: TradeItemCard(
                    docId: docs[second]['id'],
                    name: docs[second]['name'],
                    image: docs[second]['image'],
                    quantity: docs[second]['quantity'],
                    preferred:
                        (docs[second]['preferred_trades'] as List?)?.join(
                          ', ',
                        ) ??
                        'Any',
                  ),
                )
              else
                Expanded(child: Container()),
            ],
          ),
        );
      }),
    );
  }

  // --- Widget for Real Firestore ---
  Widget _buildFirestoreList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trade_listings')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading trades'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          String name = data['name'] ?? '';
          return name.toLowerCase().contains(searchText.toLowerCase());
        }).toList();

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("No trades found."),
            ),
          );
        }

        return Column(
          children: List.generate((docs.length / 2).ceil(), (index) {
            int first = index * 2;
            int second = first + 1;

            var firstData = docs[first].data() as Map<String, dynamic>;
            var firstId = docs[first].id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TradeItemCard(
                      docId: firstId,
                      name: firstData['name'] ?? 'Unknown',
                      image: firstData['image'] ?? '',
                      quantity: firstData['quantity'] ?? '',
                      preferred:
                          (firstData['preferred_trades'] as List<dynamic>?)
                              ?.join(', ') ??
                          'Any',
                    ),
                  ),
                  SizedBox(width: 12),
                  if (second < docs.length)
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          var secondData =
                              docs[second].data() as Map<String, dynamic>;
                          var secondId = docs[second].id;
                          return TradeItemCard(
                            docId: secondId,
                            name: secondData['name'] ?? 'Unknown',
                            image: secondData['image'] ?? '',
                            quantity: secondData['quantity'] ?? '',
                            preferred:
                                (secondData['preferred_trades']
                                        as List<dynamic>?)
                                    ?.join(', ') ??
                                'Any',
                          );
                        },
                      ),
                    )
                  else
                    Expanded(child: Container()),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

// Card Widgets
class TradeCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const TradeCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.green),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Trade Item Card
class TradeItemCard extends StatelessWidget {
  final String docId;
  final String name;
  final String image;
  final String quantity;
  final String preferred;

  const TradeItemCard({
    required this.docId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.preferred,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider getImageProvider() {
      if (image.startsWith('assets/')) {
        return AssetImage(image);
      } else if (image.isNotEmpty) {
        return FileImage(File(image));
      }
      return AssetImage('assets/images/default_cover_photo.png');
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfferTradePage(
              docId: docId,
              name: name,
              image: image,
              quantity: quantity,
              preferred: preferred,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Container(
          width: double.infinity,
          height: 260,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: getImageProvider(),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) =>
                        AssetImage('assets/images/default_cover_photo.png'),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '$quantity\nPreferred: $preferred',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TradeRequestPage(
                          listingId: docId,
                          listingName: name,
                        ),
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
                    minimumSize: Size(double.infinity, 40),
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

// Trade Request Page (The page where you make an offer)
class TradeRequestPage extends StatefulWidget {
  final String listingId;
  final String listingName;

  TradeRequestPage({required this.listingId, required this.listingName});

  @override
  _TradeRequestPageState createState() => _TradeRequestPageState();
}

class _TradeRequestPageState extends State<TradeRequestPage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  bool _isLoading = false;

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _submitOffer() async {
    if (itemNameController.text.isEmpty ||
        itemQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --- TESTING LOGIC --- // testing123
      if (isTesting) {
        await Future.delayed(Duration(seconds: 1)); // Simulate network delay
        print("TESTING: Offer Submitted to mock DB");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('TESTING: Trade Offer Sent!')));
        Navigator.pop(context);
        return;
      }
      // ---------------------

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('trade_offers').add({
        'listing_id': widget.listingId,
        'offered_by_uid': user.uid,
        'offered_by_name': user.displayName ?? 'Anonymous',
        'item_name': itemNameController.text,
        'item_quantity': itemQuantityController.text,
        'image_path': _pickedImage?.path ?? '',
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Trade Offer Sent!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending offer: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: BackButton(),
        title: Center(
          child: Text(
            'Trade Offer for ${widget.listingName}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Item Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(
                hintText: 'Enter Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your Item Quantity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: itemQuantityController,
              decoration: InputDecoration(
                hintText: 'Enter Item Quantity',
                border: OutlineInputBorder(),
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
                        child: Icon(Icons.add, size: 40, color: Colors.grey),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOffer,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.black)
                    : Text('Offer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC3E956),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Offer a Trade Page (Detail View of item you want to trade for)
class OfferTradePage extends StatelessWidget {
  final String docId;
  final String name;
  final String image;
  final String quantity;
  final String preferred;

  OfferTradePage({
    required this.docId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.preferred,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider getImageProvider() {
      if (image.startsWith('assets/')) return AssetImage(image);
      if (image.isNotEmpty) return FileImage(File(image));
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
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: getImageProvider(),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Item",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(quantity, style: TextStyle(fontSize: 16)),
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
                  "This item is available for trade.",
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Preferred Trades",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(preferred, style: TextStyle(fontSize: 15)),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TradeRequestPage(
                          listingId: docId,
                          listingName: name,
                        ),
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
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Make Trade Page (Create a new listing)
class MakeTradePage extends StatefulWidget {
  @override
  _MakeTradePageState createState() => _MakeTradePageState();
}

class _MakeTradePageState extends State<MakeTradePage> {
  File? _image;
  final picker = ImagePicker();

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final TextEditingController _preferredTradeController =
      TextEditingController();

  List<String> _preferredTrades = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addPreferredTrade() {
    final trade = _preferredTradeController.text.trim();
    if (trade.isNotEmpty) {
      setState(() {
        _preferredTrades.add(trade);
        _preferredTradeController.clear();
      });
    }
  }

  Future<void> _postTradeRequest() async {
    if (_itemNameController.text.isEmpty ||
        _itemQuantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide name and quantity')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --- TESTING LOGIC --- // testing123
      if (isTesting) {
        await Future.delayed(Duration(seconds: 1)); // Simulate network
        print("TESTING: New Trade Posted to mock DB");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TESTING: Trade Posted Successfully!')),
        );
        Navigator.pop(context);
        return;
      }
      // ---------------------

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance.collection('trade_listings').add({
        'name': _itemNameController.text,
        'quantity': _itemQuantityController.text,
        'preferred_trades': _preferredTrades,
        'image': _image?.path ?? '',
        'user_id': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'offers_count': 0,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Trade Posted Successfully!')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error posting trade: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Make a Trade', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  labelText: 'Enter Item Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _itemQuantityController,
                decoration: InputDecoration(
                  labelText: 'Enter Item Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text('Add Image:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _image == null
                      ? Center(
                          child: Icon(Icons.add, size: 40, color: Colors.grey),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Preferred Trades',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _preferredTradeController,
                      decoration: InputDecoration(
                        hintText: 'Add preferred trade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addPreferredTrade,
                    child: Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(50, 50),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _preferredTrades
                    .map(
                      (trade) => Chip(
                        label: Text(trade),
                        onDeleted: () {
                          setState(() {
                            _preferredTrades.remove(trade);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _postTradeRequest,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text('Post Trade Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC3E956),
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

// My Trades Page
class MyTradesPage extends StatefulWidget {
  @override
  _MyTradesPageState createState() => _MyTradesPageState();
}

class _MyTradesPageState extends State<MyTradesPage> {
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    User? user;
    if (!isTesting) {
      user = FirebaseAuth.instance.currentUser;
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
        title: Text('My Trades', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: (!isTesting && user == null)
          ? Center(child: Text("Please login to see your trades"))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => setState(() => searchText = val),
                    decoration: InputDecoration(
                      hintText: 'Search by item name...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // SWITCH LIST BUILDER BASED ON MODE
                Expanded(
                  child: isTesting
                      ? _buildMockMyTrades() // testing123
                      : _buildFirestoreMyTrades(user!), // Real
                ),
              ],
            ),
    );
  }

  // --- Mock My Trades ---
  Widget _buildMockMyTrades() {
    // Filter Mock List for a fake user ID 'test_user_uid'
    var docs = mockListings.where((doc) {
      return doc['user_id'] == 'test_user_uid' &&
          (doc['name'] ?? '').toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    if (docs.isEmpty)
      return Center(
        child: Text("You haven't posted any trades yet (Testing)."),
      );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: List.generate((docs.length / 2).ceil(), (rowIndex) {
            final int firstIndex = rowIndex * 2;
            final int secondIndex = firstIndex + 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  if (firstIndex < docs.length)
                    Expanded(child: MyTradeCard(trade: docs[firstIndex])),
                  SizedBox(width: 12),
                  if (secondIndex < docs.length)
                    Expanded(child: MyTradeCard(trade: docs[secondIndex]))
                  else
                    Expanded(child: Container()),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // --- Real My Trades ---
  Widget _buildFirestoreMyTrades(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trade_listings')
          .where('user_id', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error'));
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        var docs = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return (data['name'] ?? '').toLowerCase().contains(
            searchText.toLowerCase(),
          );
        }).toList();

        if (docs.isEmpty)
          return Center(child: Text("You haven't posted any trades yet."));

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: List.generate((docs.length / 2).ceil(), (rowIndex) {
                final int firstIndex = rowIndex * 2;
                final int secondIndex = firstIndex + 1;

                Map<String, dynamic> getData(int index) {
                  var data = docs[index].data() as Map<String, dynamic>;
                  data['id'] = docs[index].id;
                  return data;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      if (firstIndex < docs.length)
                        Expanded(
                          child: MyTradeCard(trade: getData(firstIndex)),
                        ),
                      SizedBox(width: 12),
                      if (secondIndex < docs.length)
                        Expanded(
                          child: MyTradeCard(trade: getData(secondIndex)),
                        )
                      else
                        Expanded(child: Container()),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// Card for My Trades
class MyTradeCard extends StatelessWidget {
  final Map<String, dynamic> trade;

  const MyTradeCard({required this.trade});

  @override
  Widget build(BuildContext context) {
    String image = trade['image'] ?? '';
    ImageProvider imageProvider;
    if (image.startsWith('assets/'))
      imageProvider = AssetImage(image);
    else if (image.isNotEmpty)
      imageProvider = FileImage(File(image));
    else
      imageProvider = AssetImage('assets/images/default_cover_photo.png');

    String preferred =
        (trade['preferred_trades'] as List<dynamic>?)?.join(', ') ?? 'Any';

    int offersCount = trade['offers_count'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                TradeOfferPage(listingId: trade['id'], tradeData: trade),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    onError: (e, s) =>
                        AssetImage('assets/images/default_cover_photo.png'),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                trade['name'] ?? 'Item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '${trade['quantity'] ?? ''}, Preferred: $preferred',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFC3E956),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$offersCount Offers',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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

// Trade Offer Owner (View offers on my item)
class TradeOfferPage extends StatelessWidget {
  final String listingId;
  final Map<String, dynamic> tradeData;

  TradeOfferPage({required this.listingId, required this.tradeData});

  @override
  Widget build(BuildContext context) {
    String image = tradeData['image'] ?? '';
    ImageProvider imageProvider;
    if (image.startsWith('assets/'))
      imageProvider = AssetImage(image);
    else if (image.isNotEmpty)
      imageProvider = FileImage(File(image));
    else
      imageProvider = AssetImage('assets/images/default_cover_photo.png');

    String preferred =
        (tradeData['preferred_trades'] as List<dynamic>?)?.join('\n• ') ??
        'Any';
    if (preferred != 'Any') preferred = '• $preferred';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Trade Offer', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image + Gradient Box
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
                child: Column(
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Category / Name / Quantity
              Text(
                "Item",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                tradeData['name'] ?? '',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(tradeData['quantity'] ?? '', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),

              // Product Details
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
                  "Your item posted for trade.",
                  style: TextStyle(fontSize: 15),
                ),
              ),

              SizedBox(height: 20),

              // Preferred Trades
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Preferred Trades",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(preferred, style: TextStyle(fontSize: 15)),
              ),

              SizedBox(height: 25),

              // Trade Requests
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Trade Requests",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 12),

              // Switch Stream Builder based on mode
              isTesting
                  ? _buildMockOffers(context) // testing123
                  : _buildFirestoreOffers(context), // Real
            ],
          ),
        ),
      ),
    );
  }

  // --- Mock Offers List ---
  Widget _buildMockOffers(BuildContext context) {
    if (mockOffers.isEmpty) return Text("No offers yet (Testing).");
    return Column(
      children: mockOffers.map((req) {
        return _buildOfferItem(context, req);
      }).toList(),
    );
  }

  // --- Real Firestore Offers List ---
  Widget _buildFirestoreOffers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trade_offers')
          .where('listing_id', isEqualTo: listingId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Error loading offers");
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator();

        var offers = snapshot.data!.docs;
        if (offers.isEmpty) return Text("No offers yet.");

        return Column(
          children: offers.map((doc) {
            var req = doc.data() as Map<String, dynamic>;
            return _buildOfferItem(context, req);
          }).toList(),
        );
      },
    );
  }

  // --- Shared Offer Item Widget ---
  Widget _buildOfferItem(BuildContext context, Map<String, dynamic> req) {
    String reqImage = req['image_path'] ?? '';
    ImageProvider reqImgProvider;
    if (reqImage.startsWith('assets/'))
      reqImgProvider = AssetImage(reqImage);
    else if (reqImage.isNotEmpty)
      reqImgProvider = FileImage(File(reqImage));
    else
      reqImgProvider = AssetImage('assets/images/default_cover_photo.png');

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFC3E956),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: reqImgProvider, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 12),

          // Product Name & Quantity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req['item_name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  req['item_quantity'] ?? '',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  "by: ${req['offered_by_name'] ?? 'User'}",
                  style: TextStyle(fontSize: 11, color: Colors.grey[800]),
                ),
              ],
            ),
          ),

          // Accept Button
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Accept clicked (Logic to be implemented)"),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Accept"),
          ),
        ],
      ),
    );
  }
}
