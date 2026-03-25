import 'package:flutter/material.dart';

class ExitSuccessScreen extends StatelessWidget {
  const ExitSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      // Fem servir SafeArea perquè res surti de la pantalla
      body: SafeArea( 
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrat vertical
            children: [
              const Spacer(), // Empeny cap al centre
              
              // Icona de confirmació
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF700A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFFFF700A),
                  size: 80, // Una mica més petita per seguretat
                ),
              ),
              
              const SizedBox(height: 40),
              
              const Text(
                "SERVEI FINALITZAT",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 15),
              
              const Text(
                "L'informe s'ha enviat correctament.\nEl Radar s'ha actualitzat.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF778591), fontSize: 15, height: 1.5),
              ),
              
              const Spacer(), // Empeny cap al centre
              
              // Botó inferior
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF700A),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "TORNAR AL RADAR",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 20), // Margre extra inferior per a la barra de gestos
            ],
          ),
        ),
      ),
    );
  }
}
