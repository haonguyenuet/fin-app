import 'package:fin_chart/presentation/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    final themeData = ThemeData(
      colorScheme: ColorScheme.light(),
      dividerTheme: DividerThemeData(
        space: 0,
        thickness: 1,
        color: Color(0xFFF2F2F2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );

    return themeData.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(themeData.textTheme),
    );
  }
}
