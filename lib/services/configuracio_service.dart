import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracioEmpresa {
  final double preuSedan;
  final double preuVan;
  final double margeOnlyTransfer;
  final int tempsEntreServeisMin;

  const ConfiguracioEmpresa({
    required this.preuSedan,
    required this.preuVan,
    required this.margeOnlyTransfer,
    required this.tempsEntreServeisMin,
  });

  factory ConfiguracioEmpresa.fromMap(Map<String, dynamic> map) {
    double _toDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    int _toInt(dynamic value, int fallback) {
      if (value is num) return value.toInt();
      return fallback;
    }

    return ConfiguracioEmpresa(
      preuSedan: _toDouble(map['preu_sedan'], 125),
      preuVan: _toDouble(map['preu_van'], 185),
      margeOnlyTransfer: _toDouble(map['marge_onlytransfer'], 20),
      tempsEntreServeisMin: _toInt(map['temps_entre_serveis_min'], 120),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preu_sedan': preuSedan,
      'preu_van': preuVan,
      'marge_onlytransfer': margeOnlyTransfer,
      'temps_entre_serveis_min': tempsEntreServeisMin,
    };
  }
}

class ConfiguracioService {
  static final DocumentReference<Map<String, dynamic>> _docRef =
      FirebaseFirestore.instance.collection('configuracio').doc('general');

  static Future<ConfiguracioEmpresa> obtenirConfiguracio() async {
    final doc = await _docRef.get();

    if (!doc.exists || doc.data() == null) {
      return const ConfiguracioEmpresa(
        preuSedan: 125,
        preuVan: 185,
        margeOnlyTransfer: 20,
        tempsEntreServeisMin: 120,
      );
    }

    return ConfiguracioEmpresa.fromMap(doc.data()!);
  }

  static Future<void> guardarConfiguracio({
    required double preuSedan,
    required double preuVan,
    required double margeOnlyTransfer,
    required int tempsEntreServeisMin,
  }) async {
    await _docRef.set({
      'preu_sedan': preuSedan,
      'preu_van': preuVan,
      'marge_onlytransfer': margeOnlyTransfer,
      'temps_entre_serveis_min': tempsEntreServeisMin,
      'actualitzat_el': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
