import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  final String _premiumChartId = 'charts';

  bool isAvailable = false;
  List<ProductDetails> products = [];
  bool isPremiumUser = false;

  void initialize() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      debugPrint("Error in purchase stream: $error");
    });

    _loadProducts();
    checkPremiumStatus();
  }

  Future<void> _loadProducts() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) return;

    const Set<String> kIds = <String>{'charts'};
    final ProductDetailsResponse response = await _iap.queryProductDetails(kIds);

    if (response.error == null && response.productDetails.isNotEmpty) {
      products = response.productDetails;
    }
  }

  void buyPremiumCharts() {
    if (products.isEmpty) {
      debugPrint("Product not found in store.");
      return;
    }

    final ProductDetails productDetails = products.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint("Error in purchase: ${purchaseDetails.error}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _deliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && purchaseDetails.productID == _premiumChartId) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'isPremium': true,
      }, SetOptions(merge: true));

      isPremiumUser = true;
    }
  }

  Future<void> checkPremiumStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('isPremium')) {
        isPremiumUser = doc.data()!['isPremium'];
      }
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}