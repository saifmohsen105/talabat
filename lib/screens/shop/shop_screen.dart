import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart' as model;
import '../../state/products_controller.dart';
import '../../widgets/async_state.dart';
import '../../widgets/cart_widget.dart';
import '../../widgets/product_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _search = TextEditingController();
  String? _categoryId;
  bool _didReadRoute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read the deep-link category once. Without this guard, picking "All"
    // (null) would be overwritten by the query parameter the next time
    // dependencies change (e.g. when the products controller notifies).
    if (!_didReadRoute) {
      _didReadRoute = true;
      _categoryId = GoRouterState.of(context).uri.queryParameters['category'];
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _selectCategory(String? id) => setState(() => _categoryId = id);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductsController>();
    final errorMessage = controller.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore food'),
        scrolledUnderElevation: 0,
        actions: [CartWidget(onTap: () => context.push('/cart'))],
      ),
      body: controller.isLoading
          ? const LoadingView()
          : errorMessage != null
          ? ErrorView(message: errorMessage, onRetry: controller.load)
          : _buildContent(controller),
    );
  }

  Widget _buildContent(ProductsController controller) {
    final filtered = controller.filtered(
      query: _search.text,
      categoryId: _categoryId,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _SearchField(
            controller: _search,
            onChanged: () => setState(() {}),
          ),
        ),
        _CategoryChips(
          categories: controller.categories.cast<model.Category>(),
          selectedId: _categoryId,
          onSelected: _selectCategory,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyView(message: 'No dishes match your search.')
              : GridView.builder(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            // 2 columns on phones, more on tablets.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, index) =>
                ProductCard(product: filtered[index]),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search dishes...',
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: Colors.deepOrange.shade900,
        ),
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<model.Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(
              label: const Text('All'),
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
            );
          }
          final category = categories[index - 1];
          return ChoiceChip(
            label: Text(category.name),
            selected: selectedId == category.id,
            onSelected: (_) => onSelected(category.id),
          );
        },
      ),
    );
  }
}