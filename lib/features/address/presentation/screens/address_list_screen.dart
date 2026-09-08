import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/shimmer_loading.dart';
import '../providers/address_notifier.dart';
import '../../data/models/address_model.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),
      body: addressState.when(
        data: (addresses) => addresses.isEmpty
            ? _buildEmptyState(context)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: addresses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return _AddressCard(address: address);
                },
              ),
        loading: () => const Column(
          children: [
            SizedBox(height: 16),
            _AddressPlaceholder(),
            SizedBox(height: 12),
            _AddressPlaceholder(),
          ],
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => context.push('/profile/addresses/add'),
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'No saved addresses',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Add an address for faster checkout', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final AddressModel address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: address.isDefault ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    address.label?.toUpperCase() ?? 'HOME',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (address.isDefault)
                  Text(
                    'Default',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (val) {
                    if (val == 'edit') {
                      context.push('/profile/addresses/edit', extra: address);
                    } else if (val == 'delete') {
                      ref.read(addressProvider.notifier).deleteAddress(address.id!);
                    } else if (val == 'default') {
                      ref.read(addressProvider.notifier).toggleDefault(address.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!address.isDefault)
                      const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.name ?? '',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              address.fullAddress,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Phone: ${address.phone}',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressPlaceholder extends StatelessWidget {
  const _AddressPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerWidget.rectangular(height: 100),
    );
  }
}
