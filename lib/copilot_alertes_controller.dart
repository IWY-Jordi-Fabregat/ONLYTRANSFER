import 'package:flutter/material.dart';

class CopilotAlertes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF2D3142),
        borderRadius: BorderRadius(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("ASSISTENT DE CONDUCCIÓ ACTIU", 
            style: TextStyle(color: Color(0xFFFF700A), fontSize: 12, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          
          _itemAlerta(Icons.person_pin_circle, "EL MANDAO T'ESPERA", "Client localitzat a la T1"),
          _itemAlerta(Icons.local_drink, "PETICIÓ DE CLIENT", "Aigua natural sol·licitada"),
          _itemAlerta(Icons.timer, "AVÍS DE TOUR", "Porteu 45 minuts de trajecte"),
          
          SizedBox(height: 20),
          LinearProgressIndicator(
            value: 0.8, 
            backgroundColor: Colors.white10, 
            color: Color(0xFFFF700A)
          ),
        ],
      ),
    );
  }

  Widget _itemAlerta(IconData icona, String titol, String subtitol) {
    return ListTile(
      leading: Icon(icona, color: Colors.white70),
      title: Text(titol, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitol, style: TextStyle(color: Colors.white38, fontSize: 12)),
    );
  }
}
