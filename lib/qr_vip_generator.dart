import 'package:flutter/material.dart';

class QrVipGenerator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Blanc pur, estil Apple/Japó
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("BENVINGUDA VIP", style: TextStyle(color: Color(0xFF2D3142), letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ESCANEJA PER CONNECTAR", 
              style: TextStyle(color: Color(0xFF778591), fontSize: 14, fontWeight: FontWeight.w300)),
            
            SizedBox(height: 40),
            
            // EL CODIGO QR (Simulat amb un contenidor de disseny net)
            Container(
              width: 250,
              height: 250,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF2D3142), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=WIFI:S:OnlyTransfer_VIP;T:WPA;P:Jordi2026;;',
                loadingBuilder: (context, child, progress) => progress == null ? child : CircularProgressIndicator(color: Color(0xFFFF700A)),
              ),
            ),
            
            SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _iconaInfo(Icons.wifi, "WIFI 5G"),
                SizedBox(width: 40),
                _iconaInfo(Icons.contact_phone, "CONTACTE"),
              ],
            ),
            
            SizedBox(height: 60),
            
            Text("Només per a clients OnlyTransfer", 
              style: TextStyle(color: Colors.black12, fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _iconaInfo(IconData icona, String text) {
    return Column(
      children: [
        Icon(icona, color: Color(0xFFFF700A), size: 30),
        SizedBox(height: 8),
        Text(text, style: TextStyle(color: Color(0xFF556677), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
