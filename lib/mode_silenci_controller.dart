import 'package:flutter/material.dart';

class ModeSilenciController extends StatefulWidget {
  @override
  _ModeSilenciControllerState createState() => _ModeSilenciControllerState();
}

class _ModeSilenciControllerState extends State<ModeSilenciController> {
  bool silenciActiu = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // BOTÓ PER AL CLIENT (Android 2)
          SwitchListTile(
            title: Text("DEMANAR SILENCI TOTAL", 
              style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold)),
            subtitle: Text("El xòfer rebrà l'avís immediatament."),
            secondary: Icon(Icons.volume_off, color: silenciActiu ? Color(0xFFFF700A) : Colors.grey),
            value: silenciActiu,
            activeColor: Color(0xFFFF700A),
            onChanged: (bool value) {
              setState(() {
                silenciActiu = value;
                // AQUESTA ÉS LA COMUNICACIÓ CAP AL JORDI
                _notificarAlJordi(value);
              });
            },
          ),
          
          if (silenciActiu)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("🔇 MODE RELAX ACTIVAT", 
                style: TextStyle(color: Color(0xFFFF700A), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  void _notificarAlJordi(bool actiu) {
    if (actiu) {
      print("📡 ENVIANT SENYAL A L'ANDROID 1: El client vol silenci.");
    } else {
      print("📡 ENVIANT SENYAL A L'ANDROID 1: Mode normal restaurat.");
    }
  }
}
