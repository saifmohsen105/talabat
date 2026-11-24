import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../state/cart_controller.dart';
import '../../state/orders_controller.dart';
import '../../widgets/async_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _showMessage(String message, {required bool isError}) {
    final scheme = Theme.of(context).colorScheme;
    final background = isError ? scheme.error : Colors.green.shade800;
    final foreground = isError ? scheme.onError : Colors.white;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          content: Text(message, style: TextStyle(color: foreground)),
        ),
      );
  }

  /// Requests location permission and fills the address field using GPS.
  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // 1. Make sure location services are enabled.
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS.');
      }

      // 2. Check and request permission.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. '
              'Please enable them in system settings.',
        );
      }

      // 3. Get coordinates and resolve them to an address.
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final geo.Geocoding geocoding = geo.Geocoding();
      final List<geo.Placemark> placemarks =
      await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final formattedAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.country,
        ].whereType<String>().where((part) => part.isNotEmpty).join(', ');

        setState(() => _address.text = formattedAddress);
        _showMessage('Location detected successfully', isError: false);
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _placeOrder() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cart = context.read<CartController>();
    if (cart.isEmpty) return;

    final orderId = await context.read<OrdersController>().placeOrder(
      _address.text.trim(),
      cart.items,
    );

    if (!mounted) return;
    if (orderId != null) {
      cart.clear();
      final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
      _showMessage('Order placed successfully · $shortId', isError: false);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final orders = context.watch<OrdersController>();

    if (cart.isEmpty) {
      return const Scaffold(body: EmptyView(message: 'Your cart is empty.'));
    }

    final theme = Theme.of(context);
    final errorMessage = orders.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // --- Delivery address ---
          _SectionCard(
            title: 'Delivery address',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepOrange.shade900,
                    side: BorderSide(color: Colors.deepOrange.shade700),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    _isGettingLocation ? 'Detecting...' : 'Use Current Location',
                  ),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _address,
                    readOnly: true,
                    onTap: _isGettingLocation ? null : _getCurrentLocation,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Address details',
                      hintText: 'Tap "Use Current Location" above',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.deepOrange.shade900,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    (value == null || value.trim().length < 5)
                        ? 'Please tap "Use Current Location" to detect your address.'
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Payment method ---
          _SectionCard(
            title: 'Payment method',
            child: Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  color: Colors.deepOrange.shade900,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash on delivery',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Pay when your order arrives',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green.shade700),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Order summary ---
          _SectionCard(
            title: 'Order summary',
            child: Column(
              children: [
                for (final item in cart.items)
                  _SummaryRow(
                    name: item.product.name,
                    quantity: item.quantity,
                    price: '${item.lineTotal.toStringAsFixed(0)} EGP',
                  ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Total amount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${cart.total.toStringAsFixed(0)} EGP',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            _InlineError(message: errorMessage),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: orders.isLoading ? null : _placeOrder,
          child: orders.isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'Confirm & Place Order',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

/// Outlined card with a section title.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final int quantity;
  final String price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Qty: $quantity',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: scheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}