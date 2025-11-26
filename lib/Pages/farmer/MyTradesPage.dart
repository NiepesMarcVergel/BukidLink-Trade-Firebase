import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/TradeService.dart';
import '../../models/TradeModels.dart';
import 'MakeTradePage.dart'; // Required for Edit Navigation

class MyTradesPage extends StatefulWidget {
  @override
  _MyTradesPageState createState() => _MyTradesPageState();
}

class _MyTradesPageState extends State<MyTradesPage> {
  final TradeService _tradeService = TradeService();
  TextEditingController searchController = TextEditingController();
  String searchText = '';

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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchText = val),
              decoration: InputDecoration(
                hintText: 'Search my items...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // List of My Trades
          Expanded(
            child: StreamBuilder<List<TradeListing>>(
              stream: _tradeService.getMyTrades(searchText),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error loading data'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Text("You haven't posted any trades yet."),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: List.generate(docs.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: MyTradeItemCard(
                          listing: docs[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TradeIncomingOffersPage(
                                  listing: docs[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Widget: Card for "My Trades" (Shows Offer Count) ---
class MyTradeItemCard extends StatelessWidget {
  final TradeListing listing;
  final VoidCallback onTap;

  const MyTradeItemCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (listing.image.startsWith('assets/')) {
      imageProvider = AssetImage(listing.image);
    } else if (listing.image.isNotEmpty) {
      imageProvider = FileImage(File(listing.image));
    } else {
      imageProvider = AssetImage('assets/images/default_cover_photo.png');
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                height: 80,
                width: 80,
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
              SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${listing.quantity}\nPreferred: ${listing.preferredTrades.join(', ')}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Offer Badge
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFC3E956),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${listing.offersCount} Offers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Page: View Incoming Offers for a specific Listing + EDIT/DELETE ---
class TradeIncomingOffersPage extends StatelessWidget {
  final TradeListing listing;
  final TradeService _tradeService = TradeService();

  TradeIncomingOffersPage({required this.listing});

  // --- Helper: Delete Dialog ---
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Trade?"),
        content: Text(
          "Are you sure you want to delete this listing? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await _tradeService.deleteListing(listing.id);
              Navigator.pop(context); // Go back to My Trades list
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Trade deleted.")));
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (listing.image.startsWith('assets/')) {
      imageProvider = AssetImage(listing.image);
    } else if (listing.image.isNotEmpty) {
      imageProvider = FileImage(File(listing.image));
    } else {
      imageProvider = AssetImage('assets/images/default_cover_photo.png');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trade Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          // --- EDIT / DELETE MENU ---
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Navigate to MakeTradePage in Edit Mode
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MakeTradePage(listing: listing),
                  ),
                );
              } else if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Edit"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Delete"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Item Info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1F4A2C), Color(0xFFC3E956)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            listing.quantity,
                            style: TextStyle(color: Colors.white70),
                          ),
                          // Show Description here too
                          SizedBox(height: 4),
                          Text(
                            listing.description,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Received Offers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              // Offers List
              StreamBuilder<List<TradeOfferRequest>>(
                stream: _tradeService.getOffersForListing(listing.id),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text("Error loading offers");
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  final offers = snapshot.data ?? [];

                  if (offers.isEmpty)
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("No offers received yet."),
                    );

                  return Column(
                    children: offers.map((offer) {
                      return _OfferTile(offer: offer);
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  final TradeOfferRequest offer;
  const _OfferTile({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: offer.imagePath.isNotEmpty
                ? DecorationImage(
                    image: FileImage(File(offer.imagePath)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: offer.imagePath.isEmpty
              ? Icon(Icons.image, color: Colors.grey)
              : null,
        ),
        title: Text(
          offer.itemName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${offer.itemQuantity}\nBy: ${offer.offeredByName}'),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Feature coming soon!")));
          },
          child: Text("Accept"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFC3E956),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
