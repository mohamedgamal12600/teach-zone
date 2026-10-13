// cart.dart
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/price_formatter.dart';
import '../main.dart' show cartModel, authModel;

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cartModel,
      builder: (context, _) {
        final items = cartModel.items;
        if (items.isEmpty) return _emptyCart(context);
        return Column(
          children: [
            _header(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _CartTile(item: items[i]),
              ),
            ),
            _footer(context),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('My Cart', style: text.titleLarge),
          TextButton(
            onPressed: cartModel.clear,
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal', value: 'EGP ${_fmt(cartModel.subtotal)}'),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'Delivery',
            value: cartModel.deliveryCharge == 0
                ? 'Free'
                : 'EGP ${_fmt(cartModel.deliveryCharge)}',
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'Total',
            value: 'EGP ${_fmt(cartModel.total)}',
            bold: true,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (authModel.isSignedIn) {
                  Navigator.pushNamed(context, '/checkout');
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
              child: const Text('Proceed to Checkout'),
            ),
          ),
          if (cartModel.subtotal < CartLimits.freeDeliveryThreshold)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add EGP ${_fmt(CartLimits.freeDeliveryThreshold - cartModel.subtotal)} more for free delivery',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Add products from the home screen',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Shared delivery constants.
class CartLimits {
  static const double deliveryFee = 50.0;
  static const double freeDeliveryThreshold = 2000.0;
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final dynamic item; // CartItem

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(
                p.image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyLarge?.copyWith(fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'EGP ${_fmt(p.price)}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _QtyBtn(
                icon: Icons.add,
                onTap: () => cartModel.increase(p.id),
              ),
              const SizedBox(height: 4),
              Text('${item.quantity}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 4),
              _QtyBtn(
                icon: Icons.remove,
                onTap: () => cartModel.decrease(p.id),
              ),
            ],
          ),
          IconButton(
            onPressed: () => cartModel.remove(p.id),
            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontSize: bold ? 16 : 14,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value,
            style: style?.copyWith(color: bold ? AppColors.accent : null)),
      ],
    );
  }
}
