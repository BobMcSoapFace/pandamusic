import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Map<String, Color> Function(BuildContext) colorMap = (context)=>{
  "primary": Theme.of(context).colorScheme.primary,
  "secondary": Theme.of(context).colorScheme.secondary,
  "tertiary": Theme.of(context).colorScheme.tertiary,
  "surface": Theme.of(context).colorScheme.surface,
  "onSurface": Theme.of(context).colorScheme.onSurface,
  "onPrimary": Theme.of(context).colorScheme.onPrimary
};
class ColorSchemePalette extends StatelessWidget {
  const ColorSchemePalette({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: 
      colorMap(context).entries.map<Widget>(
        (entry) => Container(
          decoration: BoxDecoration(

          ),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5
          ),
          child: Row(
            spacing: 8,
            children: [
              Container(
                width: 20,
                height: 20,
                color: entry.value,
              ),
              Text(
                entry.key,
                style: GoogleFonts.googleSans(fontSize: 16),
              ),
          ])
        )
      ).toList()
    );
  }

}