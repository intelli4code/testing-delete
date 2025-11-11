enum CodeCategory {
  qr,
  barcode,
}

class CodeType {
  final String id;
  final String name;
  final String description;
  final CodeCategory category;

  const CodeType({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
}

// Available code types for generation
class CodeTypes {
  static const List<CodeType> all = [
    // QR Codes
    CodeType(
      id: 'qr_text',
      name: 'Plain Text',
      description: 'Create a QR code with plain text',
      category: CodeCategory.qr,
    ),
    CodeType(
      id: 'qr_url',
      name: 'URL / Website',
      description: 'Create a QR code for a website link',
      category: CodeCategory.qr,
    ),
    CodeType(
      id: 'qr_wifi',
      name: 'Wi-Fi Network',
      description: 'Share Wi-Fi credentials via QR code',
      category: CodeCategory.qr,
    ),
    CodeType(
      id: 'qr_contact',
      name: 'Contact Card',
      description: 'Share contact information (vCard)',
      category: CodeCategory.qr,
    ),
    CodeType(
      id: 'qr_phone',
      name: 'Phone Number',
      description: 'Create a QR code for a phone number',
      category: CodeCategory.qr,
    ),
    CodeType(
      id: 'qr_email',
      name: 'Email',
      description: 'Create a QR code for an email',
      category: CodeCategory.qr,
    ),
    
    // Barcodes
    CodeType(
      id: 'barcode_ean13',
      name: 'EAN-13',
      description: 'Product barcode (13 digits)',
      category: CodeCategory.barcode,
    ),
    CodeType(
      id: 'barcode_code128',
      name: 'Code 128',
      description: 'General purpose barcode',
      category: CodeCategory.barcode,
    ),
    CodeType(
      id: 'barcode_itf',
      name: 'ITF',
      description: 'Interleaved 2 of 5 barcode',
      category: CodeCategory.barcode,
    ),
  ];

  static List<CodeType> getByCategory(CodeCategory category) {
    return all.where((type) => type.category == category).toList();
  }
}
