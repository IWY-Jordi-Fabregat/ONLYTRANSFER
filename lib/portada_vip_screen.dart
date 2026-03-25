import 'package:flutter/material.dart';
import 'llista_reserves_screen.dart'; // El teu radar de reserves
import 'formulari_transfer_screen.dart'; // El formulari per al client
import 'register_screen.dart'; // <--- AQUESTA ÉS LA CLAU QUE FALTA

class PortadaVipScreen extends StatelessWidget {
  const PortadaVipScreen({super.key});

  // --- EL PANY SECRET DEL CONDUCTOR ---
  void _obrirAccesConductor(BuildContext context) {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3142), // Gris Negre
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ACCÉS PRIVAT", 
          style: TextStyle(color: Color(0xFFFF700A), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 32, letterSpacing: 10),
          decoration: const InputDecoration(
            hintText: "PIN",
            hintStyle: TextStyle(color: Colors.white24, fontSize: 16),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                // EL TEU PIN: 1962 (Any de naixement)
                if (pinController.text == "1962") {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LlistaReservesScreen()));
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("PIN INCORRECTE"), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text("ENTRAR AL RADAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LA IMATGE DE LA VAN (Fons elegant)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF2D3142), // Color de seguretat si no carrega la foto
              child: Image.asset(
                'assets/logo_app.png', // Aquí pots posar la foto de la Mercedes Van si la tens als assets
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF2D3142)),
              ),
            ),
          ),
          
 // Capa de degradat fosc per a l'elegància
          Container(
            decoration: BoxDecoration(
              // HEM TRENCAT LA LÍNIA QUE DONAVA ERROR
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3), 
                  const Color(0xFF2D3142)
                ],
              ),
            ),
          ),
          // 2. CONTINGUT PRINCIPAL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // 👉 EL LOGO AMB EL SECRET: CLIC LLARG (3 SEGONS) PER A TU
                GestureDetector(
                  onLongPress: () => _obrirAccesConductor(context),
                  child: Hero(
                    tag: 'logo',
                    child: Image.asset('assets/logo_app.png', height: 120),
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text("ONLYTRANSFER",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8)),
                const Text("VIP PASSENGER SERVICE",
                  style: TextStyle(color: Color(0xFF778591), fontSize: 12, letterSpacing: 3)),
                
                const Spacer(),
                
                // 3. EL BOTÓ PER AL CLIENT (SRA. ANNA)
// EL BOTÓ ÚNIC PER AL CLIENT (SRA. ANNA)
SizedBox(
  width: double.infinity,
  height: 65,
  child: ElevatedButton(
    onPressed: () {
      // 🛑 ATENCIÓ: Aquí enviem al REGISTRE, no a la reserva directa
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => RegisterScreen())
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF700A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    child: const Text("RESERVAR TRANSPORT VIP",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
  ),
),                const SizedBox(height: 20),
                const Text("Barcelona · Madrid · Dubai", 
                  style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
