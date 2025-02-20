import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

extension DoubleExt on num {
  String formatWithThousandSeparator({int maximumFractionDigits = 2}) {
    final number = withFixedDecimal(maximumFractionDigits);
    final formatter = NumberFormat("#,##0");
    formatter.minimumFractionDigits = maximumFractionDigits;
    formatter.maximumFractionDigits = maximumFractionDigits;
    formatter.minimumIntegerDigits = 1;
    return formatter.format(number);
  }

  double withFixedDecimal(int fractionDigits) {
    final number = Decimal.parse('$this');
    final factor = Decimal.fromBigInt(BigInt.from(10).pow(fractionDigits));
    // Truncate the number to the specified maximum number of fractional digits
    return ((number * factor).truncate() / factor).toDouble();
  }

  String abbreviate({bool ignoreThousand = false, int maximumFractionDigits = 2}) {
    if (this >= 1000000000) {
      return '${(this / 1000000000).formatWithThousandSeparator(maximumFractionDigits: maximumFractionDigits)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).formatWithThousandSeparator(maximumFractionDigits: maximumFractionDigits)}M';
    } else if (this >= 1000 && !ignoreThousand) {
      return '${(this / 1000).formatWithThousandSeparator(maximumFractionDigits: maximumFractionDigits)}K';
    } else {
      return formatWithThousandSeparator(maximumFractionDigits: maximumFractionDigits);
    }
  }
}
