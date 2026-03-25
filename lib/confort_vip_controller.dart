import 'package:flutter/material.dart';

class ConfortVipController extends StatefulWidget {
  @override
  _ConfortVipControllerState createState() => _ConfortVipControllerState();
}

class _ConfortVipControllerState extends State<ConfortVipController> {
  double temperatura = 21.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text("AJUSTS DE CONFORT", 
            style: TextStyle(color: Color(0xFF2D3142), letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          SizedBox(height: 30),
          
          // CONTROL DE TEMPERATURA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _botoAjust(Icons.remove, () => setState(() => temperatura -= 0.5)),
              Column(
                children: [
                  Text("${temperatura.toStringAsFixed(1)}°C", 
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.w300, color: Color(0xFF2D3142))),
                  Text("TEMPERATURA", style: TextStyle(color: Colors.black26, fontSize: 10)),
                ],
              ),
              _botoAjust(Icons.add, () => setState(() => temperatura += 0.5)),
            ],
          ),
          
          SizedBox(height: 40),
          
          // ALTRES PETICIONS RÀPIDES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _opcioRapida(Icons.Lightbulb_outline, "LLUM"),
              _opcioRapida(Icons.Music_note, "MÚSICA"),
              _opcioRapida(Icons.Chair, "BUTACA"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _botoAjust(IconData icona, VoidCallback accio) {
    return GestureDetector(
      onTap: () {
        accio();
        print("📡 ENVIANT AJUST A L'ANDROID 1: Nova temperatura $temperatura°C");
      },
      child: CircleAvatar(
        backgroundColor: Color(0xFFF8F9FA),
        child: Icon(icona, color: Color(0xFF2D3142)),
      ),
    );
  }

  Widget _opcioRapida(IconData icona, String text) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icona, color: Color(0xFF778591)),
          onPressed: () => print("📡 PETICIÓ DE CLIENT: $text"),
        ),
        Text(text, style: TextStyle(color: Color(0xFF778591), fontSize: 10)),
      ],
    );
  }
}
