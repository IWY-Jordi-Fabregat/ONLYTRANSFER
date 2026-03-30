import 'package:flutter/material.dart';

class SuperUserMenu extends StatelessWidget {
  const SuperUserMenu({super.key});

  // Estètica Jordi: Colors Corporatius
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);
  final Color grisClar = const Color(0xFF778591);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("ONLYTRANSFER CONTROL", 
          style: TextStyle(color: grisNegre, fontSize: 14, letterSpacing: 3, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SECCIÓ 1: GESTIÓ OPERATIVA
            _buildBotoMenu(
              context,
              titol: "GESTIONAR VIATGES",
              subtitol: "Assignar serveis a operadors",
              icona: Icons.map_outlined,
              colorIcona: taronja,
              destinacio: const Placeholder(), // Aquí anirà la llista de viatges
            ),
            
            const SizedBox(height: 20),

            // SECCIÓ 2: ALTES I PARTNERS
            _buildBotoMenu(
              context,
              titol: "PANEL OPERADOR (ALTA)",
              subtitol: "Crear Empresa o Autònom",
              icona: Icons.business_center_outlined,
              colorIcona: grisNegre,
              destinacio: const Placeholder(), // Aquí anirà el formulari d'alta
            ),

            const SizedBox(height: 20),

            // SECCIÓ 3: ECONOMIA I CONTROL
            _buildBotoMenu(
              context,
              titol: "FACTURACIÓ I LLEGAT",
              subtitol: "Control d'ingressos recurrents",
              icona: Icons.account_balance_wallet_outlined,
              colorIcona: const Color(0xFF556677),
              destinacio: const Placeholder(), // Aquí anirà el teu control de 10k-15k€
            ),
            
            const SizedBox(height: 60),
            
            // PEU DE PÀGINA: L'horitzó de 30 anys
            Text("HORITZÓ VITAL: 400 MESOS DE PAU", 
              style: TextStyle(color: grisClar, fontSize: 10, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  // Funció per crear botons nets estil Apple/Jordi
  Widget _buildBotoMenu(BuildContext context, {
    required String titol, 
    required String subtitol, 
    required IconData icona, 
    required Color colorIcona,
    required Widget destinacio
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destinacio)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFF1F1F1), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Row(
          children: [
            Icon(icona, size: 30, color: colorIcona),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titol, style: TextStyle(color: grisNegre, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitol, style: TextStyle(color: grisClar, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: grisClar.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
