// screens/checkout.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/cart_model.dart';
import '../../core/state/auth_model.dart';
import '../../core/state/orders_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/price_formatter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _payment = 'Cash on Delivery';
  bool _loading = false;

  static const _paymentMethods = [
    'Cash on Delivery',
    'Credit Card',
    'Debit Card',
    'Vodafone Cash',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (context.read<CartModel>().items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }
    final uid = context.read<AuthModel>().currentUser?.uid;
    if (uid == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    setState(() => _loading = true);
    try {
      final ordersModel = context.read<OrdersModel>();
      await ordersModel.placeOrder(
        uid: uid,
        items: context.read<CartModel>().items.toList(),
        subtotal: context.read<CartModel>().subtotal,
        deliveryFee: context.read<CartModel>().deliveryCharge,
        total: context.read<CartModel>().total,
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        paymentMethod: _payment,
      );
      // Only clear the cart AFTER the order has been successfully saved.
      context.read<CartModel>().clear();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Order Placed!',
              style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Your order has been placed successfully. You can track it in My Orders.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // leave checkout
              },
              child: const Text('Great!'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = context.read<CartModel>();
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text('Delivery Information', style: text.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Full name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Phone is required.';
                if (v.trim().length < 10) return 'Enter a valid phone number.';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Shipping address',
                prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Address is required.' : null,
            ),
            const SizedBox(height: 24),
            Text('Payment Method', style: text.titleMedium),
            ...(_paymentMethods.map((m) {
              final isSelected = _payment == m;
              return InkWell(
                onTap: () => setState(() => _payment = m),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(m, style: text.bodyLarge),
                    ],
                  ),
                ),
              );
            })),
            const SizedBox(height: 24),
            Text('Order Summary', style: text.titleMedium),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: cartModel,
              builder: (_, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ...cartModel.items.map(
                      (ci) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${ci.product.name} x ${ci.quantity}',
                                style: text.bodyLarge?.copyWith(fontSize: 13),
                              ),
                            ),
                            Text(
                              PriceFormatter.formatWithCurrency(ci.product.price * ci.quantity),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    _Row('Subtotal', PriceFormatter.formatWithCurrency(cartModel.subtotal), text),
                    _Row(
                      'Delivery',
                      cartModel.deliveryCharge == 0
                          ? 'Free'
                          : PriceFormatter.formatWithCurrency(cartModel.deliveryCharge),
                      text,
                    ),
                    const Divider(height: 16),
                    _Row(
                      'Total',
                      PriceFormatter.formatWithCurrency(cartModel.total),
                      text,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _placeOrder,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.surfaceDark,
                        ),
                      )
                    : const Text('Place Order'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, this.text, {this.bold = false});

  final String label;
  final String value;
  final TextTheme text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = text.bodyLarge?.copyWith(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      fontSize: bold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
