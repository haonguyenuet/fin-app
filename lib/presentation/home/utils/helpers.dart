import 'package:fin_app/presentation/home/extensions/double_ext.dart';

String formatPrice(double price) {
  int decimalPlaces;
  if (price.abs() > 1000) {
    decimalPlaces = 2;
  } else if (price.abs() > 100) {
    decimalPlaces = 3;
  } else if (price.abs() > 10) {
    decimalPlaces = 4;
  } else if (price.abs() > 1) {
    decimalPlaces = 5;
  } else {
    decimalPlaces = 7;
  }

  return price.formatWithThousandSeparator(maximumFractionDigits: decimalPlaces);
}

String formatTime(DateTime date, {bool showTimeOfDay = true}) {
  String formattedDate = "${formatNumber(date.day)}/${formatNumber(date.month)}/${formatNumber(date.year)}";
  if (showTimeOfDay) {
    formattedDate += " ${formatNumber(date.hour)}:${formatNumber(date.minute)}";
  }
  return formattedDate;
}

/// Fomats number as 2 digit integer
String formatNumber(int value) {
  return value.toString().padLeft(2, '0');
}
