import 'package:flutter/material.dart';
import '../models/code_type.dart';
import '../screens/code_generator_screen.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Code'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'QR Codes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...CodeTypes.getByCategory(CodeCategory.qr).map(
            (type) => _CodeTypeCard(codeType: type),
          ),
          const SizedBox(height: 24),
          const Text(
            'Barcodes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...CodeTypes.getByCategory(CodeCategory.barcode).map(
            (type) => _CodeTypeCard(codeType: type),
          ),
        ],
      ),
    );
  }
}

class _CodeTypeCard extends StatelessWidget {
  final CodeType codeType;

  const _CodeTypeCard({required this.codeType});

  IconData _getIconForCodeType() {
    switch (codeType.id) {
      case 'qr_text':
        return Icons.text_fields;
      case 'qr_url':
        return Icons.link;
      case 'qr_wifi':
        return Icons.wifi;
      case 'qr_contact':
        return Icons.contact_page;
      case 'qr_phone':
        return Icons.phone;
      case 'qr_email':
        return Icons.email;
      case 'barcode_ean13':
      case 'barcode_code128':
      case 'barcode_itf':
        return Icons.qr_code_2;
      default:
        return Icons.qr_code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            _getIconForCodeType(),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          codeType.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(codeType.description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CodeGeneratorScreen(codeType: codeType),
            ),
          );
        },
      ),
    );
  }
}
