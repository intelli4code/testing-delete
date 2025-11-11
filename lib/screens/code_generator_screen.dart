import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/code_type.dart';
import '../models/barcode_template.dart';
import '../utils/action_helper.dart';

class CodeGeneratorScreen extends StatefulWidget {
  final CodeType codeType;

  const CodeGeneratorScreen({super.key, required this.codeType});

  @override
  State<CodeGeneratorScreen> createState() => _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends State<CodeGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _textController = TextEditingController();
  final _urlController = TextEditingController();
  final _ssidController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _organizationController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  
  String _wifiEncryption = 'WPA';

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _ssidController.dispose();
    _wifiPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _generateCode() {
    if (!_formKey.currentState!.validate()) return;

    String data = '';

    switch (widget.codeType.id) {
      case 'qr_text':
        data = _textController.text;
        break;
      case 'qr_url':
        data = _urlController.text;
        break;
      case 'qr_wifi':
        data = ActionHelper.generateWiFiContent(
          ssid: _ssidController.text,
          password: _wifiPasswordController.text,
          encryption: _wifiEncryption,
        );
        break;
      case 'qr_contact':
        data = ActionHelper.generateVCard(
          name: _nameController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          organization: _organizationController.text.isEmpty ? null : _organizationController.text,
        );
        break;
      case 'qr_phone':
        data = 'tel:${_phoneController.text}';
        break;
      case 'qr_email':
        data = 'mailto:${_emailController.text}';
        if (_subjectController.text.isNotEmpty || _bodyController.text.isNotEmpty) {
          data += '?';
          if (_subjectController.text.isNotEmpty) {
            data += 'subject=${Uri.encodeComponent(_subjectController.text)}';
          }
          if (_subjectController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
            data += '&';
          }
          if (_bodyController.text.isNotEmpty) {
            data += 'body=${Uri.encodeComponent(_bodyController.text)}';
          }
        }
        break;
      case 'barcode_ean13':
      case 'barcode_code128':
      case 'barcode_itf':
        data = _textController.text;
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CodeResultScreen(
          data: data,
          codeType: widget.codeType,
        ),
      ),
    );
  }

  Widget _buildForm() {
    switch (widget.codeType.id) {
      case 'qr_text':
        return TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Enter text',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter text' : null,
        );

      case 'qr_url':
        return TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Enter URL',
            hintText: 'https://example.com',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter a URL';
            if (!value!.startsWith('http://') && !value.startsWith('https://')) {
              return 'URL must start with http:// or https://';
            }
            return null;
          },
        );

      case 'qr_wifi':
        return Column(
          children: [
            TextFormField(
              controller: _ssidController,
              decoration: const InputDecoration(
                labelText: 'Network Name (SSID)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter network name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _wifiPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter password' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _wifiEncryption,
              decoration: const InputDecoration(
                labelText: 'Security Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'WPA', child: Text('WPA/WPA2')),
                DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                DropdownMenuItem(value: 'nopass', child: Text('None')),
              ],
              onChanged: (value) => setState(() => _wifiEncryption = value!),
            ),
          ],
        );

      case 'qr_contact':
        return Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _organizationController,
              decoration: const InputDecoration(
                labelText: 'Organization (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        );

      case 'qr_phone':
        return TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter phone number' : null,
        );

      case 'qr_email':
        return Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Message (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        );

      case 'barcode_ean13':
        return TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Enter 13 digits',
            hintText: '1234567890123',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 13,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter barcode number';
            if (value!.length != 13) return 'EAN-13 must be exactly 13 digits';
            if (!RegExp(r'^\d+$').hasMatch(value)) return 'Only digits allowed';
            return null;
          },
        );

      case 'barcode_code128':
        return TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Enter code',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter code' : null,
        );

      case 'barcode_itf':
        return TextFormField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Enter even number of digits',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter code';
            if (!RegExp(r'^\d+$').hasMatch(value!)) return 'Only digits allowed';
            if (value.length.isOdd) return 'Must have even number of digits';
            return null;
          },
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.codeType.name),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.codeType.description,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            _buildForm(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _generateCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Generate Code',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CodeResultScreen extends StatefulWidget {
  final String data;
  final CodeType codeType;

  const CodeResultScreen({
    super.key,
    required this.data,
    required this.codeType,
  });

  @override
  State<CodeResultScreen> createState() => _CodeResultScreenState();
}

class _CodeResultScreenState extends State<CodeResultScreen> {
  final GlobalKey _codeKey = GlobalKey();
  BarcodeTemplate _selectedTemplate = BarcodeTemplates.all[0];

  Future<void> _saveToGallery() async {
    try {
      RenderRepaintBoundary boundary =
          _codeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved successfully!\n$imagePath'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _share() async {
    try {
      RenderRepaintBoundary boundary =
          _codeKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/qr_share_${DateTime.now().millisecondsSinceEpoch}.png';
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Generated with QR & Barcode Scanner',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCode() {
    if (widget.codeType.category == CodeCategory.qr) {
      return QrImageView(
        data: widget.data,
        version: QrVersions.auto,
        size: 300.0,
        backgroundColor: _selectedTemplate.backgroundColor,
        foregroundColor: _selectedTemplate.foregroundColor,
      );
    } else {
      // Barcode
      Barcode barcodeType;
      switch (widget.codeType.id) {
        case 'barcode_ean13':
          barcodeType = Barcode.ean13();
          break;
        case 'barcode_code128':
          barcodeType = Barcode.code128();
          break;
        case 'barcode_itf':
          barcodeType = Barcode.itf();
          break;
        default:
          barcodeType = Barcode.code128();
      }

      return BarcodeWidget(
        barcode: barcodeType,
        data: widget.data,
        width: 300,
        height: 150,
        backgroundColor: _selectedTemplate.backgroundColor,
        color: _selectedTemplate.foregroundColor,
        drawText: _selectedTemplate.showLabel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Code'),
        actions: [
          PopupMenuButton<BarcodeTemplate>(
            icon: const Icon(Icons.palette),
            tooltip: 'Change Style',
            onSelected: (template) {
              setState(() {
                _selectedTemplate = template;
              });
            },
            itemBuilder: (context) => BarcodeTemplates.all.map((template) {
              return PopupMenuItem<BarcodeTemplate>(
                value: template,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: template.backgroundColor,
                        border: Border.all(
                          color: template.borderColor ?? Colors.grey,
                          width: template.borderWidth > 0 ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(template.borderRadius / 3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            template.description,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: _codeKey,
                child: Container(
                  padding: _selectedTemplate.padding,
                  decoration: BoxDecoration(
                    color: _selectedTemplate.backgroundColor,
                    borderRadius: BorderRadius.circular(_selectedTemplate.borderRadius),
                    border: _selectedTemplate.borderColor != null
                        ? Border.all(
                            color: _selectedTemplate.borderColor!,
                            width: _selectedTemplate.borderWidth,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: _buildCode(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Style: ${_selectedTemplate.name}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveToGallery,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
