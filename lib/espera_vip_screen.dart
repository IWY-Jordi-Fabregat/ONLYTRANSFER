import 'package:flutter/material.dart';

class EsperaVipScreen extends StatelessWidget {
  final Map<String, dynamic> dades;
  const EsperaVipScreen({super.key, required this.dades});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142), // Gris Negre
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, color: Color(0xFFFF700A), size: 80),
              const SizedBox(height: 30),
              const Text("RESERVA CONFIRMADA", 
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 10),
              Text("Sr./Sra. ${dades['nom_client']}", 
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const Divider(color: Colors.white10, height: 40),
              _infoVol(dades['cp'], "AEROPORT BCN T1"), // Aquí podríem posar la info del vol
              const SizedBox(height: 40),
              const Text("EL SEU XÒFER JA ESTÀ INFORMAT", 
                style: TextStyle(color: Color(0xFFFF700A), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoVol(String? cp, String terminal) {
    return Column(
      children: [
        const Text("PUNT DE RECOLLIDA:", style: TextStyle(color: Color(0xFF778591), fontSize: 10)),
        Text(terminal, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
