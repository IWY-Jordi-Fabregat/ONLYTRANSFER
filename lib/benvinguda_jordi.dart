import 'package:flutter/material.dart';

class BenvingudaJordi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142), // Gris Negre
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGOTIP (Simbolitzat amb un cercle taronja)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFFFF700A), // Taronja
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: Icon(Icons.airport_shuttle, color: Colors.white, size: 60),
            ),
            
            SizedBox(height: 40),
            
            Text("ONLYTRANSFER", 
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4)),
            
            SizedBox(height: 10),
            
            Text("Hola, Jordi Fabregat", 
              style: TextStyle(color: Colors.white70, fontSize: 18)),
            
            SizedBox(height: 60),
            
            // L'OBJECTIU DEL DIA
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "OBJECTIU: MESOS DE PAU I RECORRÈNCIA",
                style: TextStyle(color: Color(0xFFFF700A), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            
            SizedBox(height: 100),
            
            CircularProgressIndicator(color: Color(0xFFFF700A)),
            
            SizedBox(height: 20),
            Text("Carregant mètode de 30 anys...", 
              style: TextStyle(color: Colors.white24, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
