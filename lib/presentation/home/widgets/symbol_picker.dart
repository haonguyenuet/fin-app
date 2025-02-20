import 'package:fin_app/data/models/symbol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fin_app/presentation/home/home_viewmodel.dart';
import 'package:fin_app/shared/widgets/bottom_sheet_handle.dart';

class SymbolPicker extends ConsumerWidget {
  const SymbolPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSymbol = ref.watch(homeViewmodelProvider.select((value) => value.selectedSymbol));
    if (selectedSymbol == null) {
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
            Text(
              selectedSymbol.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
  List<CryptoSymbol> filteredSymbols = [];
  List<CryptoSymbol> allSymbols = [];

  @override
  void initState() {
    super.initState();
    allSymbols = ref.read(homeViewmodelProvider).symbols ?? [];
    filteredSymbols = List.of(allSymbols);
  }

  void _onSearch(query) {
    setState(() {
      filteredSymbols = allSymbols.where((symbol) => symbol.value.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedSymbol = ref.watch(homeViewmodelProvider.select((value) => value.selectedSymbol));
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
                  isSelected: symbol == selectedSymbol,
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
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
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

  Widget _buildSymbolOption({required CryptoSymbol symbol, required bool isSelected}) {
    return ListTile(
      onTap: () {
        ref.read(homeViewmodelProvider.notifier).onSymbolSelected(symbol);
        Navigator.of(context).pop();
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 4,
      ),
      title: Text(
        symbol.name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
