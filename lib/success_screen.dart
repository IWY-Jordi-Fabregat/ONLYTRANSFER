import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  // Aquesta és la línia clau que falta:
  const SuccessScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fons blanc pur
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El "Check" animat o una icona neta
            Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFFFF700A), // El teu taronja
              size: 100,
            ),
            SizedBox(height: 30),
            Text(
              "RESERVA SOL·LICITADA",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF2D3142), // Gris fosc elegant
              ),
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Gràcies per confiar en OnlyTransfer. Rebrà un correu de confirmació en uns minuts.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            SizedBox(height: 50),
            // Botó estil Apple
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D3142),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("TORNAR", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
