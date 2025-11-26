import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/TradeModels.dart';

class TradeDashboardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const TradeDashboardButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
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
      ),
    );
  }
}

class TradeListingCard extends StatelessWidget {
  final TradeListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onOfferPressed;

  const TradeListingCard({
    required this.listing,
    this.onTap,
    this.onOfferPressed,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider getImageProvider() {
      if (listing.image.startsWith('assets/')) return AssetImage(listing.image);
      if (listing.image.isNotEmpty) return FileImage(File(listing.image));
      return AssetImage('assets/images/default_cover_photo.png');
    }

    return GestureDetector(
      onTap: onTap,
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
                    onError: (e, s) =>
                        AssetImage('assets/images/default_cover_photo.png'),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                listing.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              Spacer(),
              if (onOfferPressed != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOfferPressed,
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
