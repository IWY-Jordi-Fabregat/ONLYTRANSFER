import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'identificacio_client.dart';

class IdentificacioClient extends StatelessWidget {
  final String nom;
  final String vol;
  final String desti;
  final String hora;

  const IdentificacioClient({
    super.key,
    required this.nom,
    required this.vol,
    required this.desti,
    required this.hora,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      appBar: AppBar(
        title: const Text("CONFIRMACIÓ", style: TextStyle(fontSize: 14, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Text("Revisa que tot sigui correcte:",
                  style: TextStyle(color: Color(0xFF778591), fontSize: 16)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _dada("CLIENT", nom),
                    const Divider(color: Colors.white10),
                    _dada("VOL", vol),
                    const Divider(color: Colors.white10),
                    _dada("DESTÍ", desti),
                    const Divider(color: Colors.white10),
                    _dada("HORA", hora),
                  ],
                ),
              ),
              const Spacer(),
 SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. AQUÍ NOMÉS CREEM LA RESERVA A FIREBASE
                    await FirebaseFirestore.instance.collection('reserves').add({
                      'welcome_sign': nom,
                      'vol_tren': vol,
                      'desti': desti,
                      'hora': hora,
                      'estat': 'PENDENT', 
                      'creat_el': FieldValue.serverTimestamp(),
                    });
                    
                    // 2. TORNEM AL INICI (RADAR BUIT)
                    if (context.mounted) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Viatge demanat amb èxit!")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF700A),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("CONFIRMAR I DEMANAR", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dada(String titol, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titol, style: const TextStyle(color: Color(0xFF778591), fontSize: 11)),
          Text(valor, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}
