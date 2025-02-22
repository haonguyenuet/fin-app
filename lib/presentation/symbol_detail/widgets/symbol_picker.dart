import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/shared/consts/app_color.dart';
import 'package:fin_app/shared/consts/app_typo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fin_app/presentation/symbol_detail/symbol_detail_viewmodel.dart';
import 'package:fin_app/shared/widgets/bottom_sheet_handle.dart';

class SymbolPicker extends ConsumerWidget {
  const SymbolPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSymbol = ref.watch(symbolDetailVMProvider.select((value) => value.currentSymbol));
    if (currentSymbol == null) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const _SymbolSearchSheet(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentSymbol.name, style: AppTypography.headlineMedium),
            const SizedBox(width: 2),
            const Icon(Icons.arrow_drop_down, size: 28),
          ],
        ),
      ),
    );
  }
}

class _SymbolSearchSheet extends ConsumerStatefulWidget {
  const _SymbolSearchSheet();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SymbolSearchSheetState();
}

class _SymbolSearchSheetState extends ConsumerState<_SymbolSearchSheet> {
  List<MarketSymbol> filteredSymbols = [];
  List<MarketSymbol> allSymbols = [];

  @override
  void initState() {
    super.initState();
    allSymbols = ref.read(symbolDetailVMProvider).symbols ?? [];
    filteredSymbols = List.of(allSymbols);
  }

  void _onSearch(query) {
    setState(() {
      filteredSymbols = allSymbols.where((symbol) => symbol.id.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSymbol = ref.watch(symbolDetailVMProvider.select((value) => value.currentSymbol));
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          BottomSheetHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchField(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: filteredSymbols.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final symbol = filteredSymbols[index];
                return _buildSymbolOption(
                  symbol: symbol,
                  isSelected: symbol == currentSymbol,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: _onSearch,
      style: AppTypography.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.secondaryText),
        prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
        filled: true,
        fillColor: AppColors.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSymbolOption({required MarketSymbol symbol, required bool isSelected}) {
    return ListTile(
      onTap: () {
        ref.read(symbolDetailVMProvider.notifier).onSymbolChanged(symbol);
        Navigator.of(context).pop();
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
      title: Text(
        symbol.name,
        style: AppTypography.subtitle.copyWith(
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}
