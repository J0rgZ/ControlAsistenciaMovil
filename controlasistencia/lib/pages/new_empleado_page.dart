import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/empleado.dart';
import '../services/empleado_service.dart';
import 'empleado_list_page.dart';

class NewEmployeePage extends StatefulWidget {
  const NewEmployeePage({Key? key}) : super(key: key);

  @override
  State<NewEmployeePage> createState() => _NewEmployeePageState();
}

class _NewEmployeePageState extends State<NewEmployeePage> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();

  String? _selectedSiteId;
  File? _photoFile;
  Uint8List? _photoBytes;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text('Registrar Empleado'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_dniCtrl, 'DNI', Icons.credit_card),
                  _buildTextField(_nameCtrl, 'Nombre', Icons.person),
                  _buildTextField(_lastCtrl, 'Apellidos', Icons.person_outline),
                  _buildTextField(_phoneCtrl, 'Celular', Icons.phone, TextInputType.phone),
                  _buildTextField(_emailCtrl, 'Correo', Icons.email, TextInputType.emailAddress),
                  _buildTextField(_positionCtrl, 'Cargo', Icons.work),
                  const SizedBox(height: 12),
                  _buildSiteDropdown(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      (_photoBytes != null || _photoFile != null) ? 'Reemplazar foto' : 'Tomar foto',
                    ),
                  ),
                  if (_photoBytes != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Image.memory(_photoBytes!, height: 120),
                    ),
                  if (_photoFile != null && _photoBytes == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Image.file(_photoFile!, height: 120),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: const Color(0xFF6A1B9A),
                    ),
                    child: const Text('Guardar Empleado'),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      [TextInputType type = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _buildSiteDropdown() {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('sites').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if (snapshot.hasError) return const Text('Error al cargar sedes');
        final docs = snapshot.data?.docs ?? [];
        return DropdownButtonFormField<String>(
          isExpanded: true,
          value: _selectedSiteId,
          decoration: InputDecoration(
            labelText: 'Sede (opcional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF6A1B9A)),
          ),
          items: docs
              .map((d) => DropdownMenuItem(value: d.id, child: Text(d.data()['name'] ?? d.id)))
              .toList(),
          onChanged: (value) => setState(() => _selectedSiteId = value),
        );
      },
    );
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _photoFile = null;
        });
      } else {
        setState(() {
          _photoFile = File(picked.path);
          _photoBytes = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoFile == null && _photoBytes == null) {
      _showSnackbar('Debe tomar una foto para biometría');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final employee = Employee(
        dni: _dniCtrl.text.trim(),
        firstName: _nameCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        position: _positionCtrl.text.trim(),
        siteId: _selectedSiteId,
        isActive: true,
      );

      final service = EmployeeService();
      await service.createEmployee(employee, _photoFile, _photoBytes);

      _showSnackbar('Empleado registrado');
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmployeesListPage()),
      );
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF6A1B9A)),
    );
  }

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nameCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }
}
