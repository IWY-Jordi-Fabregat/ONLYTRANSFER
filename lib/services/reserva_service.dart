import 'package:cloud_firestore/cloud_firestore.dart';

class ReservaService {
  static Future<void> gravarReserva({
    required Map<String, dynamic> dadesReserva,
  }) async {
    await FirebaseFirestore.instance.collection('reserves').add(dadesReserva);
  }
}
