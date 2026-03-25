import 'package:flutter/material.dart';

class PdfFacturaController extends StatelessWidget {
  final double importTotal = 150.0; // Import de la T1 a Barcelona VIP
  final String numFactura = "2026-0001-OT";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf, color: Color(0xFFFF700A), size: 50),
          SizedBox(height: 15),
          Text("SERVEI COMPLETAT", 
            style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text("Factura: $numFactura", style: TextStyle(color: Colors.grey, fontSize: 12)),
          
          Divider(height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Pagat:", style: TextStyle(color: Color(0xFF556677))),
              Text("$importTotal €", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
            ],
          ),
          
          SizedBox(height: 25),
          
          // BOTÓ DE DESCARREGA ESTIL APPLE
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2D3142), // Gris Negre
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                print("📂 GENERANT PDF AMB DADES DE DUBAI (IBAN AE...)");
                _mostrarAvis(context);
              },
              child: Text("DESCARREGAR FACTURA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarAvis(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("PDF generat i enviat al correu del Mànager."),
        backgroundColor: Color(0xFFFF700A),
      ),
    );
  }
}
