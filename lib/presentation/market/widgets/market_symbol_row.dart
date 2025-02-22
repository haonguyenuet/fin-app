import 'package:fin_app/data/models/symbol.dart';
import 'package:fin_app/presentation/market/market_viewmodel.dart';
import 'package:fin_app/shared/consts/app_color.dart';
import 'package:fin_app/shared/consts/app_typo.dart';
import 'package:fin_app/shared/extensions/double_ext.dart';
import 'package:fin_app/shared/utils/format_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketSymbolRow extends ConsumerWidget {
  const MarketSymbolRow({super.key, required this.symbolId});

  final String symbolId;

  static const double height = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(marketVMProvider.select((state) => state.symbolMap[symbolId]!));
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).push(MaterialPageRoute<void>(
        //   builder: (context) => SymbolDetailScreen(),
        // ));
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildAssetPairAndVolume(symbol),
            Expanded(child: _buildLastPrice(symbol)),
            _build24HrChange(symbol),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetPairAndVolume(MarketSymbol symbol) {
    final volume = symbol.snapshot?.quoteVolume;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            text: symbol.baseAsset,
            style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
            children: [
              TextSpan(
                text: ' /${symbol.quoteAsset}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          volume != null ? volume.abbreviate() : '-',
          style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _buildLastPrice(MarketSymbol symbol) {
    final lastPrice = symbol.snapshot?.lastPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          lastPrice != null ? formatPrice(lastPrice) : '-',
          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          lastPrice != null ? '\$${formatPrice(lastPrice)}' : '-',
          style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
        ),
      ],
    );
  }

  Widget _build24HrChange(MarketSymbol symbol) {
    final changePercent = symbol.snapshot?.priceChangePercent ?? 0;
    final backgroundColor = changePercent == 0
        ? AppColors.secondary
        : changePercent > 0
            ? AppColors.bull
            : AppColors.bear;
    return Container(
      width: 96,
      height: 32,
      margin: const EdgeInsets.only(left: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${changePercent.toStringAsFixed(2)}%',
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: changePercent == 0 ? AppColors.onSecondary : AppColors.onPrimary,
        ),
      ),
    );
  }
}
