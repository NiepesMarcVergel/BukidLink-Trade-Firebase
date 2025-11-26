import 'package:flutter/material.dart';
import 'package:bukidlink/widgets/farmer/FarmerAppBar.dart';
import 'package:bukidlink/widgets/farmer/FarmerBottomNavBar.dart';
import 'package:bukidlink/widgets/farmer/TradeWidgets.dart';
import 'package:bukidlink/services/TradeService.dart';
import 'package:bukidlink/models/TradeModels.dart';
import 'MakeTradePage.dart';
import 'MyTradesPage.dart';
import 'OfferTradePage.dart';

class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final TradeService _tradeService = TradeService();
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
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchText = value),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // Top Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TradeDashboardButton(
                            title: 'Make a Trade',
                            icon: Icons.add_shopping_cart,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MakeTradePage(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: TradeDashboardButton(
                            title: 'My Trades',
                            icon: Icons.list_alt,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MyTradesPage()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Listings Grid
                    StreamBuilder<List<TradeListing>>(
                      stream: _tradeService.getTradeListings(searchText),
                      builder: (context, snapshot) {
                        if (snapshot.hasError)
                          return Center(child: Text('Error loading trades'));
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return Center(child: CircularProgressIndicator());

                        final listings = snapshot.data ?? [];
                        if (listings.isEmpty)
                          return Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("No trades found."),
                          );

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio:
                                    0.65, // Adjust based on your card height
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: listings.length,
                          itemBuilder: (context, index) {
                            final item = listings[index];
                            return TradeListingCard(
                              listing: item,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        OfferTradePage(listing: item),
                                  ),
                                );
                              },
                              onOfferPressed: () {
                                // Navigate to Offer Page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        OfferTradePage(listing: item),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
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
