import 'package:flutter/material.dart';

class ConversorDivisa extends StatefulWidget {
  @override
  _ConversorDivisaState createState() => _ConversorDivisaState();
}

class _ConversorDivisaState extends State<ConversorDivisa> {
  double euros = 100.0;
  final double canviAED = 4.02; // Taxa de canvi aproximada (1€ = 4.02 AED)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142),
      appBar: AppBar(
        title: Text("CONTROL DE DIVISA DUBAI", style: TextStyle(color: Colors.white, fontSize: 14)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SECCIÓ EUROS (BARCELONA)
            _blocMoneda("EUROS (EUR)", euros.toStringAsFixed(2), "€", Colors.white70),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(Icons.sync_alt, color: Color(0xFFFF700A), size: 40),
            ),
            
            // SECCIÓ DIRHAMS (DUBAI)
            _blocMoneda("DIRHAMS (AED)", (euros * canviAED).toStringAsFixed(2), "د.إ", Color(0xFFFF700A)),
            
            SizedBox(height: 60),
            
            Text("Taxa de canvi actualitzada: 1 EUR = $canviAED AED", 
              style: TextStyle(color: Colors.white24, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _blocMoneda(String titol, String valor, String simbol, Color colorValor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(titol, style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(valor, style: TextStyle(color: colorValor, fontSize: 40, fontWeight: FontWeight.bold)),
              SizedBox(width: 10),
              Text(simbol, style: TextStyle(color: colorValor.withOpacity(0.5), fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
