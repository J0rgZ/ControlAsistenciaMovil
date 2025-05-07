import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'new_empleado_page.dart';

class EmployeesListPage extends StatefulWidget {
  const EmployeesListPage({super.key});

  @override
  State<EmployeesListPage> createState() => _EmployeesListPageState();
}

class _EmployeesListPageState extends State<EmployeesListPage> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A),
        title: const Text('Empleados'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o cargo',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('employees').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay empleados registrados.'));
                }

                final query = _searchCtrl.text.toLowerCase();
                final employees = snapshot.data!.docs.where((doc) {
                  final data = doc.data();
                  final fullName = '${data['firstName']} ${data['lastName']}'.toLowerCase();
                  final position = data['position']?.toString().toLowerCase() ?? '';
                  return fullName.contains(query) || position.contains(query);
                }).toList();

                if (employees.isEmpty) {
                  return const Center(child: Text('No se encontraron empleados.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final data = employees[index].data();
                    final initials = '${data['firstName']?[0] ?? ''}${data['lastName']?[0] ?? ''}';

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFCE93D8),
                                  child: Text(initials.toUpperCase(), style: const TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${data['firstName']} ${data['lastName']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(data['position'] ?? '', style: const TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 2),
                                      Text(data['email'] ?? '', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.fingerprint, size: 16),
                                    SizedBox(width: 4),
                                    Text('No registrado'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      data['isActive'] == true ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        color: data['isActive'] == true ? Colors.green : Colors.red,
                                      ),
                                    ),
                                    Switch(
                                      value: data['isActive'] == true,
                                      onChanged: (val) {
                                        FirebaseFirestore.instance
                                            .collection('employees')
                                            .doc(employees[index].id)
                                            .update({'isActive': val});
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewEmployeePage()),
        ),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Empleado'),
      ),
      backgroundColor: const Color(0xFFF2F2F2),
    );
  }
}
