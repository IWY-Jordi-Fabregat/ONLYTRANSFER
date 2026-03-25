import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ENVIAR FACTURA AL NÚVOL (SEGURETAT DUBAI)
  Future<void> guardarFactura({
    required String client,
    required double import,
    required String cp,
    required String ciutat,
  }) async {
    try {
      await _db.collection('factures').add({
        'client': client,
        'import': import,
        'cp': cp,
        'ciutat': ciutat,
        'data': FieldValue.serverTimestamp(), // Hora exacta del servidor
        'estat': 'Pendent de liquidació',
      });
      print("✅ Factura blindada al núvol de OnlyTransfer");
    } catch (e) {
      print("❌ Error en la sincronització: $e");
    }
  }
}
