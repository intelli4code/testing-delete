import 'package:flutter/material.dart';

enum BarcodeStyle {
  standard,
  minimal,
  colorful,
  framed,
  rounded,
}

class BarcodeTemplate {
  final String id;
  final String name;
  final String description;
  final BarcodeStyle style;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final bool showLabel;
  final TextStyle? labelStyle;

  const BarcodeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.style,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.borderColor,
    this.borderWidth = 0,
    this.borderRadius = 0,
    this.padding = const EdgeInsets.all(20),
    this.showLabel = true,
    this.labelStyle,
  });
}

class BarcodeTemplates {
  static const List<BarcodeTemplate> all = [
    BarcodeTemplate(
      id: 'standard',
      name: 'Standard',
      description: 'Classic black and white style',
      style: BarcodeStyle.standard,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: EdgeInsets.all(20),
    ),
    BarcodeTemplate(
      id: 'minimal',
      name: 'Minimal',
      description: 'Clean and simple design',
      style: BarcodeStyle.minimal,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: EdgeInsets.all(10),
      showLabel: false,
    ),
    BarcodeTemplate(
      id: 'colorful_blue',
      name: 'Blue Ocean',
      description: 'Blue gradient background',
      style: BarcodeStyle.colorful,
      backgroundColor: Color(0xFF2196F3),
      foregroundColor: Colors.white,
      padding: EdgeInsets.all(25),
      borderRadius: 12,
    ),
    BarcodeTemplate(
      id: 'colorful_green',
      name: 'Green Nature',
      description: 'Green professional style',
      style: BarcodeStyle.colorful,
      backgroundColor: Color(0xFF4CAF50),
      foregroundColor: Colors.white,
      padding: EdgeInsets.all(25),
      borderRadius: 12,
    ),
    BarcodeTemplate(
      id: 'framed_black',
      name: 'Black Frame',
      description: 'Elegant black border',
      style: BarcodeStyle.framed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderColor: Colors.black,
      borderWidth: 3,
      padding: EdgeInsets.all(20),
    ),
    BarcodeTemplate(
      id: 'framed_gold',
      name: 'Golden Frame',
      description: 'Premium gold border',
      style: BarcodeStyle.framed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderColor: Color(0xFFFFD700),
      borderWidth: 4,
      padding: EdgeInsets.all(22),
    ),
    BarcodeTemplate(
      id: 'rounded_purple',
      name: 'Purple Round',
      description: 'Modern rounded purple style',
      style: BarcodeStyle.rounded,
      backgroundColor: Color(0xFF9C27B0),
      foregroundColor: Colors.white,
      padding: EdgeInsets.all(25),
      borderRadius: 20,
    ),
    BarcodeTemplate(
      id: 'rounded_orange',
      name: 'Orange Round',
      description: 'Vibrant rounded orange style',
      style: BarcodeStyle.rounded,
      backgroundColor: Color(0xFFFF9800),
      foregroundColor: Colors.white,
      padding: EdgeInsets.all(25),
      borderRadius: 20,
    ),
  ];

  static BarcodeTemplate getById(String id) {
    return all.firstWhere(
      (template) => template.id == id,
      orElse: () => all[0],
    );
  }
}
