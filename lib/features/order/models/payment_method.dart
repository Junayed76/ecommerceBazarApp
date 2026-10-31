import 'package:flutter/material.dart';

/// Payment options offered at checkout.
///
/// The card and wallet options are simulated; they only record the chosen
/// method on the order instead of contacting a real gateway.
enum PaymentMethod {
  cashOnDelivery(
    label: 'Cash on delivery',
    description: 'Pay the courier when the parcel arrives',
    icon: Icons.payments_outlined,
  ),
  card(
    label: 'Credit or debit card',
    description: 'Simulated card payment',
    icon: Icons.credit_card_rounded,
  ),
  wallet(
    label: 'Mobile wallet',
    description: 'Simulated wallet payment',
    icon: Icons.account_balance_wallet_outlined,
  );

  const PaymentMethod({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;

  static PaymentMethod fromName(String? name) {
    return PaymentMethod.values.firstWhere(
      (method) => method.name == name,
      orElse: () => PaymentMethod.cashOnDelivery,
    );
  }
}
