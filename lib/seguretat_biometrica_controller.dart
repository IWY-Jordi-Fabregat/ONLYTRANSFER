import 'package:flutter/material.dart';

class SeguretatBiometrica extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142), // Gris Negre
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICONA DE SEGURETAT ESTIL APPLE
            Icon(Icons.fingerprint, color: Color(0xFFFF700A), size: 80),
            
            SizedBox(height: 30),
            
            Text("ONLYTRANSFER SECURE", 
              style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.bold)),
            
            SizedBox(height: 10),
            
            Text("Identifica't per gestionar Dubai", 
              style: TextStyle(color: Colors.white38, fontSize: 14)),
            
            SizedBox(height: 60),
            
            // BOTÓ D'ACCÉS
            GestureDetector(
              onTap: () {
                print("🔒 VALIDANT EMPRENTA D'EN JORDI...");
                _simularAcces(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFF700A)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text("ENTRAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            
            SizedBox(height: 40),
            
            // AVÍS DE SEGURETAT
            Text("Dades encriptades sota protocols de Dubai", 
              style: TextStyle(color: Colors.white10, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _simularAcces(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Accés concedit. Hola Jordi."),
        backgroundColor: Colors.green.withOpacity(0.5),
      ),
    );
  }
}
