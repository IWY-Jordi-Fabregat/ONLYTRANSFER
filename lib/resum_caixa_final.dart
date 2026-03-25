import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'exit_success_screen.dart'; // La pantalla de confirmació

class ResumCaixaFinal extends StatefulWidget {
  final String reservaId;

  const ResumCaixaFinal({super.key, required this.reservaId});

  @override
  _ResumCaixaFinalState createState() => _ResumCaixaFinalState();
}

class _ResumCaixaFinalState extends State<ResumCaixaFinal> {
  final TextEditingController _notesInternesController = TextEditingController();
  bool _enviant = false;

  Future<void> _tancarServeiOficialment() async {
    setState(() => _enviant = true);
    try {
      await FirebaseFirestore.instance
          .collection('reserves')
          .doc(widget.reservaId)
          .update({
        'estat': 'FINALITZAT',
        'notes_conductor': _notesInternesController.text,
        'hora_finalitzacio_real': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ExitSuccessScreen()),
        );
      }
    } catch (e) {
      setState(() => _enviant = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error en tancar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      appBar: AppBar(
        title: const Text("TANCAMENT DEL SERVEI", 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Icon(Icons.playlist_add_check_circle, color: Color(0xFFFF700A), size: 80),
            const SizedBox(height: 20),
            const Text("INFORME DE FINALITZACIÓ", 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Indica si hi ha hagut alguna incidència durant el trajecte.",
              textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF778591), fontSize: 13)),
            
            const SizedBox(height: 40),
            
            TextField(
              controller: _notesInternesController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Exemple: El client ha demanat una parada extra...",
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            
            const Spacer(),
            
            if (_enviant)
              const CircularProgressIndicator(color: Color(0xFFFF700A))
            else
              ElevatedButton(
                onPressed: _tancarServeiOficialment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF700A),
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("CONFIRMAR FINAL DEL SERVEI", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
