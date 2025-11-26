import 'package:cloud_firestore/cloud_firestore.dart';

class TradeListing {
  final String id;
  final String name;
  final String quantity;
  final String description; // <--- NEW FIELD
  final List<String> preferredTrades;
  final String image;
  final String userId;
  final int offersCount;
  final DateTime createdAt;

  TradeListing({
    required this.id,
    required this.name,
    required this.quantity,
    required this.description, // <--- Add to constructor
    required this.preferredTrades,
    required this.image,
    required this.userId,
    required this.offersCount,
    required this.createdAt,
  });

  factory TradeListing.fromMap(Map<String, dynamic> data, String docId) {
    return TradeListing(
      id: docId,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? '',
      description: data['description'] ?? '', // <--- Read from Firestore
      preferredTrades: List<String>.from(data['preferred_trades'] ?? []),
      image: data['image'] ?? '',
      userId: data['user_id'] ?? '',
      offersCount: data['offers_count'] ?? 0,
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'description': description, // <--- Write to Firestore
      'preferred_trades': preferredTrades,
      'image': image,
      'user_id': userId,
      'offers_count': offersCount,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}

class TradeOfferRequest {
  final String id;
  final String listingId;
  final String offeredByUid;
  final String offeredByName;
  final String itemName;
  final String itemQuantity;
  final String imagePath;
  final String status;

  TradeOfferRequest({
    this.id = '',
    required this.listingId,
    required this.offeredByUid,
    required this.offeredByName,
    required this.itemName,
    required this.itemQuantity,
    required this.imagePath,
    this.status = 'pending',
  });

  factory TradeOfferRequest.fromMap(Map<String, dynamic> data, String docId) {
    return TradeOfferRequest(
      id: docId,
      listingId: data['listing_id'] ?? '',
      offeredByUid: data['offered_by_uid'] ?? '',
      offeredByName: data['offered_by_name'] ?? '',
      itemName: data['item_name'] ?? '',
      itemQuantity: data['item_quantity'] ?? '',
      imagePath: data['image_path'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listing_id': listingId,
      'offered_by_uid': offeredByUid,
      'offered_by_name': offeredByName,
      'item_name': itemName,
      'item_quantity': itemQuantity,
      'image_path': imagePath,
      'status': status,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
