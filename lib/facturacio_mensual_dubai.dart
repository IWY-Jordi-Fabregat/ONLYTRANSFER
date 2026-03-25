import 'package:flutter/material.dart';

class FacturacioMensual extends StatelessWidget {
  // Simulació del mes de Març
  final double acumulatMes = 12450.0;
  final int serveisRealitzats = 42;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142), // Gris Negre
      appBar: AppBar(
        title: Text("ESTAT DE FACTURACIÓ - MARÇ", style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            // CERCLE DE PROGRESSIÓ (Estil Apple Watch)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: acumulatMes / 15000, // Objectiu 15k
                    strokeWidth: 12,
                    color: Color(0xFFFF700A),
                    backgroundColor: Colors.white10,
                  ),
                ),
                Column(
                  children: [
                    Text("TOTAL MES", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    Text("${acumulatMes.toInt()}€", 
                      style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 50),
            
            // DETALL DE CLIENTS CORPORATIUS
            _filaClient("MICROSOFT CORP", "4.200 €", "12 serveis"),
            _filaClient("APPLE INC", "3.850 €", "9 serveis"),
            _filaClient("SOMB (VIP)", "4.400 €", "21 serveis"),
            
            Spacer(),
            
            // BOTÓ DE TANCAMENT DE MES
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF700A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  print("📩 ENVIANT PACK DE FACTURES A COMPTABILITAT DUBAI...");
                },
                child: Text("TANCAR MES I ENVIAR A DUBAI", 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaClient(String nom, String import, String quantitat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nom, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(quantitat, style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
          Text(import, style: TextStyle(color: Color(0xFFFF700A), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
