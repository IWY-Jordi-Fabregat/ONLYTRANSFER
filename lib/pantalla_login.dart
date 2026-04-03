import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; 
import 'pantalla_conductor.dart'; 

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _pinController = TextEditingController();
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);

  void _verificarPin() async {
    // Netegem i tallem a 6 caràcters
    String textNet = _pinController.text.trim().toUpperCase();
    if (textNet.length > 6) textNet = textNet.substring(0, 6);

    if (textNet.isEmpty) return;

    try {
      // --- EL CANVI MÀGIC ÉS AQUÍ ---
      // Hem canviat 'pin' per 'codi_seguretat' que és com està a Firebase
      var snapshot = await FirebaseFirestore.instance
          .collection('xofers')
          .where('codi_seguretat', isEqualTo: textNet)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String idSecret = snapshot.docs.first.id; 
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaConductor(uidConductor: idSecret),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("CODI INCORRECTE"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ERROR: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car_filled, size: 80, color: taronja),
                const SizedBox(height: 20),
                Text("ONLYTRANSFER", style: TextStyle(color: grisNegre, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2)),
                const SizedBox(height: 40),
                
                TextField(
                  controller: _pinController,
                  obscureText: false,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  inputFormatters: [LengthLimitingTextInputFormatter(6)],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: grisNegre, letterSpacing: 5),
                  decoration: InputDecoration(
                    hintText: "2M8Z9C",
                    hintStyle: const TextStyle(letterSpacing: 0, color: Colors.grey, fontSize: 14),
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFFF2F2F7),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: taronja, width: 2)),
                  ),
                  onSubmitted: (v) => _verificarPin(),
                ),
                
                const SizedBox(height: 30),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: taronja,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: _verificarPin,
                  child: const Text("ENTRAR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
