import 'package:flutter/material.dart';
import 'formulari_transfer_screen.dart';

class MainSelectorScreen extends StatelessWidget {
  const MainSelectorScreen({super.key});

  // Els teus colors corporatius corregits
  final Color taronjaJordi = const Color(0xFFFF700A);
  final Color grisFoscJordi = const Color(0xFF556677);
  final Color grisNegreJordi = const Color(0xFF2D3142);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisNegreJordi,
      appBar: AppBar(
        title: const Text("ONLYTRANSFER VIP", 
          style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildBoto(context, "TRANSFER ESTÀNDARD", Icons.flight_takeoff, const FormulariTransferScreen()),
            const SizedBox(height: 20),
            _buildBoto(context, "DISPOSICIÓ PER HORES", Icons.access_time, null),
            const SizedBox(height: 20),
            _buildBoto(context, "SERVEIS ESPECIALS", Icons.stars, null),
            const Spacer(),
            Text("Benvingut, Jordi Fabregat", 
              style: TextStyle(color: grisFoscJordi, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoto(BuildContext context, String titol, IconData icona, Widget? desti) {
    return InkWell(
      onTap: () {
        if (desti != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => desti));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opció disponible properament"))
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: taronjaJordi.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icona, color: taronjaJordi, size: 30),
            const SizedBox(width: 20),
            Text(titol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 15),
          ],
        ),
      ),
    );
  }
}
