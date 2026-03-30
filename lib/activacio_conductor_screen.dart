import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivacioConductorScreen extends StatefulWidget {
  const ActivacioConductorScreen({super.key});

  @override
  State<ActivacioConductorScreen> createState() => _ActivacioConductorScreenState();
}

class _ActivacioConductorScreenState extends State<ActivacioConductorScreen> {
  final _codiController = TextEditingController();
  bool _carregant = false;

  // COLORS CORPORATIUS JORDI
  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);
  final Color grisClar = const Color(0xFF778591);

  Future<void> _activarApp() async {
    if (_codiController.text.isEmpty) return;

    setState(() => _carregant = true);

    try {
      // Busquem el codi d'activació a la col·lecció 'staff'
      final query = await FirebaseFirestore.instance
          .collection('staff')
          .where('codi_activacio', isEqualTo: _codiController.text.toUpperCase())
          .where('app_activada', isEqualTo: false)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Codi correcte! Marquem com activada i vinculem el dispositiu (simulat)
        await query.docs.first.reference.update({
          'app_activada': true,
          'data_activacio': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        
        // Èxit: Anem al menú de treball del conductor
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("BENVINGUT A ONLYTRANSFER"), backgroundColor: Colors.green),
        );
        
        // Aquí el portaries a la teva pantalla de llista de viatges
        // Navigator.pushReplacement(...)
        
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("CODI INCORRECTE O JA UTILITZAT")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _carregant = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO O ICONA (Simplicitat japonesa)
              Icon(Icons.vpn_key_outlined, size: 80, color: taronja),
              const SizedBox(height: 40),
              
              Text("ONLYTRANSFER", 
                style: TextStyle(color: grisNegre, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
              const SizedBox(height: 10),
              Text("SISTEMA D'ACTIVACIÓ VIP", 
                style: TextStyle(color: grisClar, fontSize: 12, letterSpacing: 1.5)),
              
              const SizedBox(height: 60),

              // CAMPO DE TEXTO (Estil Apple)
              TextField(
                controller: _codiController,
                textAlign: TextAlign.center,
                maxLength: 5,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 10),
                decoration: InputDecoration(
                  hintText: "XXXXX",
                  counterText: "", // Amaguem el comptador per neteja visual
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: grisClar.withOpacity(0.3))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: taronja, width: 2)),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              
              const SizedBox(height: 20),
              Text("Introdueix el codi d'activació que t'ha facilitat l'administrador.",
                textAlign: TextAlign.center,
                style: TextStyle(color: grisClar, fontSize: 13, height: 1.5)),

              const SizedBox(height: 60),

              // BOTÓ D'ACTIVACIÓ
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _carregant ? null : _activarApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: grisNegre,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _carregant 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("ACTIVAR DISPOSITIU", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
