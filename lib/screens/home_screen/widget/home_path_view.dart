import 'package:flutter/material.dart';
import 'package:kiddylingo/data/data.dart';
import 'package:kiddylingo/screens/home_screen/home_screen.dart';

class HomePathView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: categoryOrder.asMap().entries.map((entry) {
            final unitIndex = entry.key;
            final category = entry.value;
            final meta = categoryMetadata[category]!;
            return UnitSection(
                category: category, meta: meta, unitIndex: unitIndex);
          }).toList(),
        ),
      ),
    );
  }
}
