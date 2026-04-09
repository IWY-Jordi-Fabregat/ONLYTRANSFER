import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

// Importacions de les teves pantalles
import 'experiencia_client.dart'; 
import 'pantalla_conductor.dart';
import 'web_gestion.dart';
import 'pantalla_login.dart';
import 'pantalla_client_web.dart'; 
import 'package:flutter_stripe/flutter_stripe.dart';

// Aquesta és la importació que ara ja trobarà
import 'package:universal_html/html.dart' as html; 

// AQUESTES DUES LÍNIES HAN D'ESTAR AQUÍ DALT (FORA DE LES CLASSES)
Map<String, dynamic> _textos = {};
String t(String clau) => _textos[clau] ?? clau;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Stripe.publishableKey = "pk_live_51STR81CX4HEsyF2lGFbls5T2jhL414nSTRg7eBx43RudaSEfGj38oStBOQZtNOVvXG8b8yNx0EHJyRPccayq0Okb000AiWTOjN";
    await Stripe.instance.applySettings();
  } catch (e) {
    print("🚨 Error inicialitzant: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Widget pantallaInicial;

    if (kIsWeb) {
      final String currentUrl = html.window.location.href;
      if (currentUrl.contains('reserva')) {
        pantallaInicial = const PantallaClientWeb();
      } else {
        pantallaInicial = const PantallaTreballDiari();
      }
    } else {
      pantallaInicial = const PantallaReceptor();
    }

    return MaterialApp(
      title: 'OnlyTransfer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Apple',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: pantallaInicial,
    );
  }
}

// RESTA DEL CODI (PantallaReceptor, etc.) SENSE TOCAR RES MÉS
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
      } catch (e2) {
        _textos = {};
      }
    }
    setState(() => _carregat = true);
  }

  void _gestionarAccesConductor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idSecret = prefs.getString('id_conductor_persistent');
    if (idSecret != null && idSecret.isNotEmpty) {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaConductor(uidXofer: idSecret)));
    } else {
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaLogin()));
    }
  }

  // ... (Aquí hi va la teva funció _mostrarDialegCodi i el Build que ja tenies) ...
  // Recorda copiar el mètode build de la PantallaReceptor que tenies abans.
  
  @override
  Widget build(BuildContext context) {
    if (!_carregat) return const Scaffold(backgroundColor: Color(0xFF2D3142));
    double ample = MediaQuery.of(context).size.width;
    double alt = MediaQuery.of(context).size.height;

    return Scaffold(
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ACCÉS PRIVAT",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF778591), letterSpacing: 2)),
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.stars_outlined, color: Color(0xFFFF700A)),
                  title: const Text("EL MEU VIATGE",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2D3142))),
                  onTap: () {
                    // Aquí crides a la funció que tenies
                  },
                ),
                const Divider(height: 40, color: Color(0xFFF1F1F1)),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/fons_app.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.35)),
          Center(child: Image.asset('assets/imatges/onlytransfer_logo.png', height: 130)),
          Positioned(
            bottom: alt * 0.05,
            left: ample * 0.08,
            right: ample * 0.08,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExperienciaClient())),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(t('receptor_boto').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text(t('receptor_lema'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
