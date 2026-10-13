// orders.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/state/orders_model.dart';
import '../../core/state/auth_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/price_formatter.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    final uid = context.read<AuthModel>().currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final ordersModel = context.read<OrdersModel>();
      await ordersModel.loadOrders(uid);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Text('Failed to load orders:\n$_error', style: text.bodyMedium),
      );
    } else if (context.watch<OrdersModel>().orders.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text('No orders yet', style: text.titleMedium),
            const SizedBox(height: 8),
            Text('Your placed orders will appear here', style: text.bodyMedium),
          ],
        ),
      );
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: context.watch<OrdersModel>().orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder:
            (_, i) => _OrderCard(order: context.watch<OrdersModel>().orders[i]),
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('My Orders')), body: body);
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final AppOrder order;

  Color _chipColor(String status) => switch (status) {
    'active' => AppColors.accent,
    'completed' => Colors.green,
    'cancelled' => AppColors.danger,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final d = order.createdAt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${order.id.substring(0, 8).toUpperCase()}',
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _chipColor(order.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _chipColor(order.status)),
                ),
                child: Text(
                  order.status[0].toUpperCase() + order.status.substring(1),
                  style: TextStyle(
                    color: _chipColor(order.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${d.day}/${d.month}/${d.year}', style: text.labelSmall),
          const SizedBox(height: 12),
          ...order.items.map(
            (li) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${li.productName} x ${li.quantity}',
                      style: text.bodyMedium,
                    ),
                  ),
                  Text(
                    PriceFormatter.formatWithCurrency(
                      li.unitPrice * li.quantity,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                PriceFormatter.formatWithCurrency(order.total),
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
