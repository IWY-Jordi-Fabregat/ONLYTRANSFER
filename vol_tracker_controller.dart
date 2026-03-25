import 'package:flutter/material.dart';

class VolTrackerController extends StatelessWidget {
  final String numeroVol = "EK185"; // Emirates Dubai -> BCN
  final String estat = "ATERRAT";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF556677).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFFF700A).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("VOL EN SEGUIMENT", style: TextStyle(color: Colors.white38, fontSize: 10)),
              Text(numeroVol, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFFFF700A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(estat, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
