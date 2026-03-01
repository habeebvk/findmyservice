import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final String _apiKey = "rzp_test_SK3czV5wEJKwOX";

  Function(PaymentSuccessResponse)? onSuccess;
  Function(PaymentFailureResponse)? onFailure;
  Function(ExternalWalletResponse)? onExternalWallet;

  RazorpayService({this.onSuccess, this.onFailure, this.onExternalWallet}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) onSuccess!(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) onFailure!(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onExternalWallet != null) onExternalWallet!(response);
  }

  void openPayment({
    required int amount, // amount in paise
    required String name,
    required String description,
    required String contact,
    required String email,
  }) {
    var options = {
      'key': _apiKey,
      'amount': amount,
      'name': name,
      'description': description,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      debugPrint("Opening Razorpay with options: $options");
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
