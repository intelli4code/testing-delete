import 'package:hive/hive.dart';

part 'scan_history.g.dart';

@HiveType(typeId: 0)
class ScanHistory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  String type; // 'url', 'text', 'wifi', 'phone', 'email', 'product', 'contact'

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  bool isFavorite;

  ScanHistory({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isFavorite = false,
  });

  // Detect the type of scanned content
  static String detectType(String content) {
    if (content.startsWith('http://') || content.startsWith('https://')) {
      return 'url';
    } else if (content.startsWith('WIFI:')) {
      return 'wifi';
    } else if (content.startsWith('tel:') || _isPhoneNumber(content)) {
      return 'phone';
    } else if (content.startsWith('mailto:') || _isEmail(content)) {
      return 'email';
    } else if (content.startsWith('BEGIN:VCARD')) {
      return 'contact';
    } else if (_isProductBarcode(content)) {
      return 'product';
    }
    return 'text';
  }

  static bool _isPhoneNumber(String text) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(text);
  }

  static bool _isEmail(String text) {
    final emailRegex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
    return emailRegex.hasMatch(text);
  }

  static bool _isProductBarcode(String text) {
    // Check if it's a numeric barcode (EAN, UPC, etc.)
    final numericRegex = RegExp(r'^\d{8,13}$');
    return numericRegex.hasMatch(text);
  }
}
