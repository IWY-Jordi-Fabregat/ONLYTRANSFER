import 'package:flutter/material.dart';

// 1. El motor que arrenca l'App
void main() {
  runApp(const OnlyTransferApp());
}

// 2. La configuració general de l'estil (Colors i tipografia)
class OnlyTransferApp extends StatelessWidget {
  const OnlyTransferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlyTransfer',
      debugShowCheckedModeBanner: false, // Fora la banda vermella de "Debug"
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFFFF700A), // El teu taronja
      ),
      home: const PantallaPrincipal(),
    );
  }
}

// 3. La pantalla blanca que conté el teu mòdul
class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        // Fem que el contingut no xocqui amb la càmera del mòbil
        child: SingleChildScrollView(
          child: ModulReservaClient(),
        ),
      ),
    );
  }
}

// 4. El teu disseny (ModulReservaClient)
class ModulReservaClient extends StatelessWidget {
  const ModulReservaClient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40), // Una mica d'aire a dalt (estil japonès)
          const Text(
            'Reserva el teu Transfer',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142), // Gris Negre
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 40),

          _campEntrada(
            icona: Icons.calendar_today_outlined,
            etiqueta: 'Data i hora de recollida',
          ),
          const SizedBox(height: 16),

          _campEntrada(
            icona: Icons.my_location_outlined,
            etiqueta: 'On et recollim?',
          ),
          const SizedBox(height: 16),

          _campEntrada(
            icona: Icons.location_on_outlined,
            etiqueta: 'A quina direcció vas?',
          ),
          const SizedBox(height: 50),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF700A), // Taronja corporatiu
              padding: const EdgeInsets.symmetric(vertical: 20),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Aquí anirà la lògica de dema
            },
            child: const Text(
              'Confirmar Reserva',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campEntrada({required IconData icona, required String etiqueta}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Un gris molt tènue per als camps
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF778591).withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(icona, color: const Color(0xFF556677)),
          border: InputBorder.none,
          labelText: etiqueta,
          labelStyle: const TextStyle(color: Color(0xFF778591)),
        ),
      ),
    );
  }
}
