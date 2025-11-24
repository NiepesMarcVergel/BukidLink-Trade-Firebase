import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';

// Trade Page Main
class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  // Mock Trade Items
  final List<Map<String, String>> tradeItems = [
    {
      'name': 'Tomato',
      'image': 'assets/images/tomato.png',
      'quantity': '3 kg',
      'preferred': 'Grapes',
    },
    {
      'name': 'Mango',
      'image': 'assets/images/mango.png',
      'quantity': '5 kg',
      'preferred': 'Apples',
    },
    {
      'name': 'Grapes',
      'image': 'assets/images/grapes.png',
      'quantity': '3 kg',
      'preferred': 'Onions',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filtered list based on search
    List<Map<String, String>> filteredItems = tradeItems
        .where(
          (item) =>
              item['name']!.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();

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

                    // Trade Items in rows of 2
                    ...List.generate((filteredItems.length / 2).ceil(), (
                      index,
                    ) {
                      int first = index * 2;
                      int second = first + 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TradeItemCard(
                                name: filteredItems[first]['name']!,
                                image: filteredItems[first]['image']!,
                                quantity: filteredItems[first]['quantity']!,
                                preferred: filteredItems[first]['preferred']!,
                              ),
                            ),
                            SizedBox(width: 12),
                            if (second < filteredItems.length)
                              Expanded(
                                child: TradeItemCard(
                                  name: filteredItems[second]['name']!,
                                  image: filteredItems[second]['image']!,
                                  quantity: filteredItems[second]['quantity']!,
                                  preferred:
                                      filteredItems[second]['preferred']!,
                                ),
                              )
                            else
                              Expanded(
                                child: Container(),
                              ), // empty for alignment
                          ],
                        ),
                      );
                    }),
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
  final String name;
  final String image;
  final String quantity;
  final String preferred;

  const TradeItemCard({
    required this.name,
    required this.image,
    required this.quantity,
    required this.preferred,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OfferTradePage(name: name, image: image, quantity: quantity),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Container(
          width: double.infinity,
          height: 230,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),

              // Name
              Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),

              // Quantity & Preferred
              Text(
                '$quantity, Preferred: $preferred',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),

              Spacer(),

              // Offer a Trade Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TradeRequestPage(name: name, image: image),
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

// Trade Request Page
class TradeRequestPage extends StatefulWidget {
  final String name;
  final String image;

  TradeRequestPage({required this.name, required this.image});

  @override
  _TradeRequestPageState createState() => _TradeRequestPageState();
}

class _TradeRequestPageState extends State<TradeRequestPage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
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
            'Trade Request',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: itemNameController,
              decoration: InputDecoration(
                hintText: 'Enter Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Item Quantity',
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
                onPressed: () {
                  // Example: show data in console or upload logic
                  print('Item Name: ${itemNameController.text}');
                  print('Quantity: ${itemQuantityController.text}');
                  print('Image Path: ${_pickedImage?.path}');
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Trade Offer Sent!')));
                },
                child: Text('Offer'),
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

// Offer a Trade Page Mock Page for now, extension from Trade Page Main

class OfferTradePage extends StatelessWidget {
  final String name;
  final String image;
  final String quantity;

  OfferTradePage({
    required this.name,
    required this.image,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Top AppBar
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

      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gradient Box + Image
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
                child: Column(children: [Image.asset(image, height: 140)]),
              ),

              SizedBox(height: 16),

              // Category
              Text(
                "Fruit",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),

              SizedBox(height: 4),

              // Name
              Text(
                name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 4),

              // Quantity
              Text(quantity, style: TextStyle(fontSize: 16)),

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
                  "Picked at the peak of ripeness, our fresh red tomatoes bring natural sweetness. "
                  "Bursting with juice, they're perfect for salad.",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("• Grapes"),
                    Text("• Apples"),
                    Text("• Sitaw"),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Offer a Trade Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TradeRequestPage(name: name, image: image),
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

//Make Trade Page

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

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Add preferred trade to the list
  void _addPreferredTrade() {
    final trade = _preferredTradeController.text.trim();
    if (trade.isNotEmpty) {
      setState(() {
        _preferredTrades.add(trade);
        _preferredTradeController.clear();
      });
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
              // Display list of preferred trades
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
                  onPressed: () {
                    // Handle trade posting here
                    print('Item Name: ${_itemNameController.text}');
                    print('Quantity: ${_itemQuantityController.text}');
                    print('Preferred Trades: $_preferredTrades');
                    print('Image Path: ${_image?.path}');
                  },
                  child: Text('Post Trade Request'),
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
  // Mock trade data
  final List<Map<String, dynamic>> allTrades = [
    {
      'name': 'Tomato',
      'image': 'assets/images/tomato.png',
      'quantity': '3 kg',
      'preferred': 'Grapes',
      'offers': 5,
    },
    {
      'name': 'Mango',
      'image': 'assets/images/mango.png',
      'quantity': '5 kg',
      'preferred': 'Apples',
      'offers': 3,
    },
    {
      'name': 'Grapes',
      'image': 'assets/images/grapes.png',
      'quantity': '3 kg',
      'preferred': 'Onions',
      'offers': 0,
    },
  ];

  List<Map<String, dynamic>> filteredTrades = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredTrades = allTrades;
    searchController.addListener(_filterTrades);
  }

  void _filterTrades() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredTrades = allTrades
          .where((trade) => trade['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by item name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Scrollable cards
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: List.generate((filteredTrades.length / 2).ceil(), (
                    rowIndex,
                  ) {
                    final int firstIndex = rowIndex * 2;
                    final int secondIndex = firstIndex + 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          // First card
                          if (firstIndex < filteredTrades.length)
                            Expanded(
                              child: MyTradeCard(
                                trade: filteredTrades[firstIndex],
                              ),
                            ),
                          SizedBox(width: 12),
                          // Second card
                          if (secondIndex < filteredTrades.length)
                            Expanded(
                              child: MyTradeCard(
                                trade: filteredTrades[secondIndex],
                              ),
                            )
                          else
                            Expanded(child: Container()), // Empty space
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card for My Trades
class MyTradeCard extends StatelessWidget {
  final Map<String, dynamic> trade;

  const MyTradeCard({required this.trade});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TradeOfferPage(trade: trade)),
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
                    image: AssetImage(trade['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                trade['name'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '${trade['quantity']}, Preferred: ${trade['preferred']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                    '${trade['offers']} Offers',
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

// Trade Offer Owner extension from My Trades Page

class TradeOfferPage extends StatelessWidget {
  final Map<String, dynamic> trade;

  TradeOfferPage({required this.trade});

  final List<Map<String, dynamic>> tradeRequests = [
    {'name': 'Mango', 'image': 'assets/images/mango.png', 'quantity': '2 kg'},
    {
      'name': 'Strawberry',
      'image': 'assets/images/strawberry.png',
      'quantity': '1 kg',
    },
    {'name': 'Onion', 'image': 'assets/images/onion.png', 'quantity': '½ kg'},
  ];

  @override
  Widget build(BuildContext context) {
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
                  children: [Image.asset(trade['image'], height: 140)],
                ),
              ),
              SizedBox(height: 16),

              // Category / Name / Quantity (centered)
              Text(
                "Fruit",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 4),
              Text(
                trade['name'],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(trade['quantity'], style: TextStyle(fontSize: 16)),
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
                  "Picked at the peak of ripeness, our fresh red tomatoes bring natural sweetness. "
                  "Bursting with juice, they're perfect for salad.",
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• Grapes"),
                    Text("• Apples"),
                    Text("• Sitaw"),
                  ],
                ),
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

              Column(
                children: tradeRequests.map((req) {
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
                            image: DecorationImage(
                              image: AssetImage(req['image']),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),

                        // Product Name & Quantity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                req['quantity'],
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        // Accept Button
                        ElevatedButton(
                          onPressed: () {},
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
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/// paghihiwalayin pa ito sa ibat ibang files :3 but ito na muna for working view ng Trades
/// note ginawa ko po ito gamit web view kaya sorry po if magulo sa part ninyo yung formatting, sorry agad