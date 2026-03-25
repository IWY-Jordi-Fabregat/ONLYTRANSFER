import 'package:flutter/material.dart';

class EsperaVipScreen extends StatelessWidget {
  final Map<String, dynamic> dades;
  
  const EsperaVipScreen({super.key, required this.dades});

  @override
  Widget build(BuildContext context) {
    // Recuperem el 'nom_client' real que hem guardat al resum
    final nomClient = dades['nom_client'] ?? "Client VIP";
    final desti = dades['desti'] ?? "---";
    final vol = dades['vol_tren'] ?? "---";
    final hora = dades['hora'] ?? "---";

    return Scaffold(
      // Fem servir el teu GRIS NEGRE #2D3142 per a un acabat Premium
      backgroundColor: const Color(0xFF2D3142), 
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icona de verificació en TARONJA #FF700A
            const Icon(Icons.check_circle_outline, color: Color(0xFFFF700A), size: 90),
            
            const SizedBox(height: 40),
            
            const Text("RESERVA CONFIRMADA", 
              style: TextStyle(
                color: Colors.white, 
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 3
              )
            ),
            
            const SizedBox(height: 20),
            
            // Salutació personalitzada amb el NOM DEL CLIENT
            Text("Benvingut/da, $nomClient", 
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 18, fontStyle: FontStyle.italic)
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Divider(color: Colors.white10, thickness: 1),
            ),
            
            // Bloc de resum del viatge (Simplicitat Apple)
            _buildDadaResum("DESTINACIÓ", desti),
            const SizedBox(height: 25),
            _buildDadaResum("VOL / TREN", vol),
            const SizedBox(height: 25),
            _buildDadaResum("HORA DE RECOLLIDA", hora),
            
            const SizedBox(height: 60),
            
            // Missatge final de tranquil·litat
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFFF700A).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10)
              ),
              child: const Text("EL SEU XÒFER JA HA ESTAT NOTIFICAT", 
                style: TextStyle(
                  color: Color(0xFFFF700A), 
                  fontSize: 11, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funció per crear cada línia de dades amb ordre i claredat
  Widget _buildDadaResum(String etiqueta, String valor) {
    return Column(
      children: [
        Text(etiqueta, 
          style: const TextStyle(color: Color(0xFF778591), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2)
        ),
        const SizedBox(height: 6),
        Text(valor, 
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)
        ),
      ],
    );
  }
}
