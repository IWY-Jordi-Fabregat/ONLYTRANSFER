import 'package:flutter/material.dart';
import 'formulari_transfer_screen.dart'; // Molt important!

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("QUÈ NECESSITA?", 
          style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3142),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildOptionCard(
              context,
              title: "TRANSFER ESTÀNDARD",
              subtitle: "Aeroport, Estació o Ciutat",
              icon: Icons.local_taxi_rounded,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FormulariTransferScreen()));
              },
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              title: "DISPOSICIÓ PER HORES",
              subtitle: "Lloguer amb conductor",
              icon: Icons.access_time_filled_rounded,
              onTap: () {
                // Aquí anirem al formulari d'hores properament
              },
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              title: "SERVEIS ESPECIALS",
              subtitle: "Esdeveniments i Grups",
              icon: Icons.star_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF778591).withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFFF700A).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFFFF700A), size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF778591))),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF556677), size: 16),
          ],
        ),
      ),
    );
  }
}
