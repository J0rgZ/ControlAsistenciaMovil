import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  final _sitesRef = FirebaseFirestore.instance.collection('sites');

  Future<void> seedSites(List<Map<String, dynamic>> sites) async {
    final existing = await _sitesRef.get();
    if (existing.docs.isNotEmpty) return;
    
    final batch = FirebaseFirestore.instance.batch();
    for (var s in sites) {
      final doc = _sitesRef.doc();
      batch.set(doc, {
        'name': s['name'],
        'latitude': s['latitude'],
        'longitude': s['longitude'],
      });
    }
    await batch.commit();
  }
}
