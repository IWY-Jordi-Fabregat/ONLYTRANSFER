import 'package:flutter/material.dart';
import 'cli_reserves.dart';

class CliBenvinguda extends StatelessWidget {
  const CliBenvinguda({super.key});

  // Funció per recuperar els textos (connectat amb el teu sistema de traducció)
  // t(context, "receptor_boto") -> "SOL·LICITAR SERVEI"
  // t(context, "receptor_lema") -> "El vostre temps, el nostre compromís"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FONS D'IMATGE ORIGINAL
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fons_app.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // 2. CAPA DE PROTECCIÓ VISUAL (Apple style)
          Container(color: Colors.black.withOpacity(0.35)),

          // 3. LOGO AL CENTRE DEL CENTRE + ACCÉS CONDUCTOR
          Center(
            child: GestureDetector(
              onDoubleTap: () {
                // ACCÉS SECRET: El conductor fa doble clic al logo per entrar
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const ExperienciaClient(pasInicial: 7))
                );
              },
              child: Image.asset(
                'assets/logo_onlyt.png',
                width: MediaQuery.of(context).size.width * 0.60, // Mida equilibrada
              ),
            ),
          ),

          // 4. UN SOL BOTÓ A LA PART INFERIOR (CLIENT)
          Positioned(
            bottom: 80, 
            left: 0,
            right: 0,
            child: Center(
              child: _botoTransparent(
                context, 
                "REQUEST SERVICE", // Aquí pots posar t(context, "receptor_boto")
                "Your time, our commitment", // Aquí pots posar t(context, "receptor_lema")
                () {
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const ExperienciaClient())
                  );
                }
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botoTransparent(BuildContext context, String titol, String subtitol, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.25), 
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titol.toUpperCase(), 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 18, 
                fontWeight: FontWeight.w400, 
                letterSpacing: 2,
              )
            ),
            const SizedBox(height: 5),
            Text(
              subtitol, 
              style: TextStyle(
                color: Colors.white.withOpacity(0.7), 
                fontSize: 10,
                fontWeight: FontWeight.w300,
              )
            ),
          ],
        ),
      ),
    );
  }
}
