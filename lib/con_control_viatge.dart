import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class ConControlViatge extends StatelessWidget {
  final String reservaId;
  final Map<String, dynamic> dades;
  final VoidCallback onFinalitzat;
  final VoidCallback onTornar;
  final VoidCallback onObrirXat;

  const ConControlViatge({
    super.key,
    required this.reservaId,
    required this.dades,
    required this.onFinalitzat,
    required this.onTornar,
    required this.onObrirXat,
  });

  final Color colorTaronjaVIP = const Color(0xFFFF700A);
  final Color colorGrisNegre = const Color(0xFF2D3142);

  // --- EL MOTOR DE LOGÍSTICA ---
  Future<void> _actualitzarEstat(String nouNomEstat, int numPas) async {
    try {
      // 1. Capturem l'hora i intentem el GPS
      String horaIso = DateTime.now().toIso8601String();
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      } catch (e) {
        pos = null;
      }

      // 2. Preparem el "calaix" LOG_X
      String campLog = "LOG_$numPas";

      // 3. Actualitzem Firebase d'un sol cop
      await FirebaseFirestore.instance.collection('reserves').doc(reservaId).update({
        'estat_servei': nouNomEstat,
        campLog: {
          'hora': horaIso,
          'lat': pos?.latitude ?? 0.0,
          'lng': pos?.longitude ?? 0.0,
          'fet': true,
        }
      });

      // 4. Si hem arribat al final del camí, tanquem el cercle
      if (nouNomEstat == 'FINALITZAT' || numPas == 6) {
        onFinalitzat();
      }
    } catch (e) {
      debugPrint("Error OnlyTransfer: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String estat = (dades['estat_servei'] ?? 'ASSIGNAT').toString().trim().toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onTornar),
        title: Text(dades['client']?.toString().toUpperCase() ?? "SERVEI", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        backgroundColor: colorGrisNegre,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.white), onPressed: onObrirXat),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _blocInfo("RECOLLIR A:", dades['origen']),
          const Divider(height: 1),
          _blocInfo("PORTAR A:", dades['desti']),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(25),
            child: _selectorDeBoto(estat),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- EL SELECTOR DE MARCHES (6 PASSOS) ---
  Widget _selectorDeBoto(String estat) {
    if (estat == 'ASSIGNAT' || estat == 'PENDENT' || estat == '') {
      return _boto("SURTO DE LA BASE", () => _actualitzarEstat('EN CAMÍ', 1));
    } else if (estat == 'EN CAMÍ') {
      return _boto("JA SÓC AL LLOC", () => _actualitzarEstat('AL LLOC', 2));
    } else if (estat == 'AL LLOC') {
      return _boto("CLIENTS A BORD", () => _actualitzarEstat('AMB EL CLIENT', 3));
    } else if (estat == 'AMB EL CLIENT') {
      return _boto("ARRIBADA PUNT 1", () => _actualitzarEstat('PUNT 1', 4));
    } else if (estat == 'PUNT 1') {
      return _boto("ARRIBADA PUNT 2", () => _actualitzarEstat('PUNT 2', 5));
    } else if (estat == 'PUNT 2') {
      return _boto("FINALITZAR / TORNAR BASE", () => _actualitzarEstat('FINALITZAT', 6));
    }
    return const SizedBox();
  }

  Widget _blocInfo(String t, String? v) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: TextStyle(color: colorTaronjaVIP, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(v?.toUpperCase() ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF2D3142), letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _boto(String t, VoidCallback tap) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: colorTaronjaVIP, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: tap,
        child: Text(t, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }
}
