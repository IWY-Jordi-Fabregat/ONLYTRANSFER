import 'package:flutter/material.dart';
import 'dart:math'; // Per generar el codi aleatori

class AltaOperadorScreen extends StatefulWidget {
  const AltaOperadorScreen({super.key});

  @override
  State<AltaOperadorScreen> createState() => _AltaOperadorScreenState();
}

class _AltaOperadorScreenState extends State<AltaOperadorScreen> {
  final TextEditingController _nomEmpresaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _codiGenerat = "";

  // Funció per generar un codi de 5 dígits únic per a l'operador
  void _generarCodi() {
    var rng = Random();
    setState(() {
      _codiGenerat = (10000 + rng.nextInt(90000)).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ALTA NOU OPERADOR", 
          style: TextStyle(color: Color(0xFF2D3142), fontSize: 14, letterSpacing: 2)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D3142)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("NOM DE L'EMPRESA O AUTÒNOM", style: TextStyle(color: Color(0xFF778591), fontSize: 12)),
            TextField(
              controller: _nomEmpresaController,
              decoration: const InputDecoration(hintText: "Ex: Vips Barcelona SL"),
            ),
            const SizedBox(height: 30),
            const Text("EMAIL DE CONTACTE", style: TextStyle(color: Color(0xFF778591), fontSize: 12)),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(hintText: "correu@empresa.com"),
            ),
            const SizedBox(height: 40),
            
            if (_codiGenerat.isNotEmpty) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFF700A), width: 2)
                  ),
                  child: Column(
                    children: [
                      const Text("CODI D'ACCÉS PER A L'OPERADOR", style: TextStyle(fontSize: 10)),
                      Text(_codiGenerat, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 10, color: Color(0xFF2D3142))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (_codiGenerat.isEmpty) {
                    _generarCodi();
                  } else {
                    // AQUÍ GUARDAREM A FIREBASE (Ho farem en el següent pas)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Operador registrat correctament"), backgroundColor: Colors.green)
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3142)),
                child: Text(_codiGenerat.isEmpty ? "GENERAR CODI" : "FINALITZAR I GUARDAR", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
