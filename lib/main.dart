import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

import 'experiencia_client.dart'; 
import 'pantalla_conductor.dart';
import 'web_gestion.dart';
import 'pantalla_login.dart';
import 'pantalla_client_web.dart'; // La que hem creat avui

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

Map<String, dynamic> _textos = {};
String t(String clau) => _textos[clau] ?? clau;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlyTransfer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Apple'),
      
      // --- INTEGRACIÓ DE LA RUTA WEB SENSE TOCAR L'ESTRUCTURA ---
      onGenerateRoute: (settings) {
        // Si entrem per web amb /v/codi, anem a la pantalla de client
        if (settings.name != null && settings.name!.startsWith('/v/')) {
          final idViatge = settings.name!.substring(3);
          return MaterialPageRoute(
            builder: (context) => PantallaClientWeb(idViatge: idViatge),
          );
        }
        // Per a tota la resta, l'app segueix el seu camí normal
        return null; 
      },

      // Mantinc la teva lògica de home intacta
      home: kIsWeb ? const PantallaTreballDiari() : const PantallaReceptor(),
    );
  }
}

// --- A PARTIR D'AQUÍ, EL TEU CODI ÉS EXACTAMENT IGUAL, NO HE TOCAT RES ---

class PantallaReceptor extends StatefulWidget {
  const PantallaReceptor({super.key});
  @override
  State<PantallaReceptor> createState() => _PantallaReceptorState();
}

class _PantallaReceptorState extends State<PantallaReceptor> {
  bool _carregat = false;

  @override
  void initState() {
    super.initState();
    _carregarTot();
  }

  Future<void> _carregarTot() async {
    Locale locale = WidgetsBinding.instance.platformDispatcher.locales.first;
    String codi = "${locale.languageCode}_${locale.countryCode?.toLowerCase() ?? locale.languageCode}";
    try {
      String json = await rootBundle.loadString('assets/lang/$codi.json');
      _textos = jsonDecode(json);
    } catch (e) {
      try {
        String json = await rootBundle.loadString('assets/lang/ca_es.json');
        _textos = jsonDecode(json);
      } catch (e2) { _textos = {}; }
    }
    setState(() => _carregat = true);
  }

  void _gestionarAccesConductor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idSecret = prefs.getString('id_conductor_persistent');
    
    if (idSecret != null && idSecret.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaConductor(uidConductor: idSecret)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaLogin()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_carregat) return const Scaffold(backgroundColor: Color(0xFF2D3142));
    double ample = MediaQuery.of(context).size.width;
    double alt = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/fons_app.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.35)), 

          Center(
            child: Image.asset(
              'assets/imatges/onlytransfer_logo.png', 
              height: 130, 
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white),
            ),
          ),

          Positioned(
            bottom: alt * 0.05, 
            left: ample * 0.08, right: ample * 0.08,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExperienciaClient())),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  children: [
                    Text(t('receptor_boto').toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text(t('receptor_lema'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: alt * 0.35, left: ample * 0.25,
            child: GestureDetector(
              onDoubleTap: () => _gestionarAccesConductor(),
              child: Container(width: 200, height: 200, color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
