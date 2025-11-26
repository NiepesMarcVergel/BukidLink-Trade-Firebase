import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/TradeModels.dart';

class TradeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TOGGLE TESTING HERE
  static const bool isTesting =
      false; // testing123: Change to false to use Firebase, and true to use mock

  // --- MOCK DATA ---
  final List<TradeListing> _mockListings = [
    TradeListing(
      id: '1',
      name: 'Sack of Rice (Sinandomeng)',
      quantity: '2 Sacks',
      description: 'Harvested last week. Good quality rice.',
      preferredTrades: ['Vegetables', 'Native Chicken'],
      image: 'assets/images/sample_rice.png',
      userId: 'test_user_uid',
      offersCount: 5,
      createdAt: DateTime.now(),
    ),
    TradeListing(
      id: '2',
      name: 'Fresh Tilapia',
      quantity: '5 Kilos',
      description: 'Fresh from the pond. Big sizes.',
      preferredTrades: ['Fruits', 'Fertilizer'],
      image: '',
      userId: 'other_user',
      offersCount: 1,
      createdAt: DateTime.now(),
    ),
  ];

  // --- READ LISTINGS ---
  Stream<List<TradeListing>> getTradeListings(String searchText) {
    if (isTesting) {
      // Return filtered mock data as a stream
      var filtered = _mockListings
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchText.toLowerCase()),
          )
          .toList();
      return Stream.value(filtered);
    } else {
      // Return Firestore Stream
      return _db
          .collection('trade_listings')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) {
                  return TradeListing.fromMap(doc.data(), doc.id);
                })
                .where((item) {
                  return item.name.toLowerCase().contains(
                    searchText.toLowerCase(),
                  );
                })
                .toList();
          });
    }
  }

  // --- READ MY TRADES ---
  Stream<List<TradeListing>> getMyTrades(String searchText) {
    User? user = _auth.currentUser;
    if (!isTesting && user == null) return Stream.value([]);

    String uid = isTesting ? 'test_user_uid' : user!.uid;

    if (isTesting) {
      var filtered = _mockListings
          .where(
            (item) =>
                item.userId == uid &&
                item.name.toLowerCase().contains(searchText.toLowerCase()),
          )
          .toList();
      return Stream.value(filtered);
    } else {
      return _db
          .collection('trade_listings')
          .where('user_id', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) {
                  return TradeListing.fromMap(doc.data(), doc.id);
                })
                .where((item) {
                  return item.name.toLowerCase().contains(
                    searchText.toLowerCase(),
                  );
                })
                .toList();
          });
    }
  }

  // --- CREATE LISTING ---
  /* Future<void> createListing(TradeListing listing) async {
    if (isTesting) {
      await Future.delayed(Duration(seconds: 1));
      _mockListings.add(listing);
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // Overwrite UID in case of some error happened
    var data = listing.toMap();
    data['user_id'] = user.uid;

    await _db.collection('trade_listings').add(data);
  }
*/

  // bypass user null error for testing
  Future<void> createListing(TradeListing listing) async {
    if (isTesting) {
      await Future.delayed(Duration(seconds: 1));
      _mockListings.add(listing);
      return;
    }

    // --- TEMPORARY FIX: USE DUMMY ID IF NOT LOGGED IN ---
    User? user = _auth.currentUser;
    String userId = user?.uid ?? 'test_user_123'; // <--- Fallback ID

    var data = listing.toMap();
    data['user_id'] = userId; // Use the ID (real or fake)

    await _db.collection('trade_listings').add(data);
  }

  // --- CREATE OFFER ---
  Future<void> submitOffer(TradeOfferRequest offer) async {
    if (isTesting) {
      await Future.delayed(Duration(seconds: 1));
      return;
    }
    await _db.collection('trade_offers').add(offer.toMap());
  }

  Stream<List<TradeOfferRequest>> getOffersForListing(String listingId) {
    return _db
        .collection('trade_offers')
        .where('listing_id', isEqualTo: listingId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return TradeOfferRequest.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
