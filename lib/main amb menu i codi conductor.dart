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
import 'pantalla_client_web.dart'; 
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:html' as html;

void main() async {
  // 1. Assegurem que Flutter estigui llest
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Inicialitzem Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Configurem la clau de Stripe
    Stripe.publishableKey = "pk_live_51STR81CX4HEsyF2lGFbls5T2jhL414nSTRg7eBx43RudaSEfGj38oStBOQZtNOVvXG8b8yNx0EHJyRPccayq0Okb000AiWTOjN";

    // 4. Intentem aplicar els settings
    try {
      await Stripe.instance.applySettings();
      print("✅ Stripe a punt");
    } catch (e) {
      print("⚠️ Stripe ha avisat d'un error de tema, però seguim: $e");
    }

  } catch (e) {
    print("🚨 Error inicialitzant serveis: $e");
  }

  // 5. LLENCEM L'APP
  runApp(const MyApp());
}

Map<String, dynamic> _textos = {};
String t(String clau) => _textos[clau] ?? clau;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
Widget build(BuildContext context) {
  // Mirem què hi ha escrit a la barra d'adreces del navegador
  final String currentUrl = html.window.location.href;

  // Si la URL conté la paraula 'reserva', ensenyem la pantalla blanca
  // Si no, ensenyem la teva pantalla de gestió
  Widget pantallaInicial;
  if (currentUrl.contains('reserva')) {
    pantallaInicial = const PantallaClientWeb();
  } else {
    pantallaInicial = kIsWeb ? const PantallaTreballDiari() : const PantallaReceptor();
  }

  return MaterialApp(
    title: 'OnlyTransfer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.orange,
      fontFamily: 'Apple',
      scaffoldBackgroundColor: Colors.white,
    ),
    home: pantallaInicial, // Aquí decidim quina pantalla obre segons la URL
  );
}
}
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

  // NOVA FUNCIÓ: Quadre de diàleg per al codi de 8 dígits
void _mostrarDialegCodi(BuildContext context) {
  final TextEditingController _codiController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: const Text("EL TEU VIATGE", 
        textAlign: TextAlign.center, 
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, color: Color(0xFF2D3142))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Camp 1: El Codi de Reserva
          TextField(
            controller: _codiController,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3, color: Color(0xFFFF700A)),
            decoration: const InputDecoration(
              labelText: "CODI DE RESERVA",
              labelStyle: TextStyle(fontSize: 10, color: Colors.grey),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF700A))),
            ),
          ),
          const SizedBox(height: 20),
          
          // Camp 2: La Contrasenya (OnlyTransfer)
          TextField(
            controller: _passController,
            textAlign: TextAlign.center,
            obscureText: true, // Perquè no es vegi el que escrius
            style: const TextStyle(fontSize: 18, color: Color(0xFF2D3142)),
            decoration: const InputDecoration(
              labelText: "CONTRASENYA",
              labelStyle: TextStyle(fontSize: 10, color: Colors.grey),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF556677))),
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3142),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
onPressed: () async {
  String codi = _codiController.text.trim().toUpperCase();
  // Fem que la contrasenya no distingeixi majúscules/minúscules per evitar mails de suport
  String pass = _passController.text.trim().toLowerCase(); 

  // Validació "intel·ligent"
  if (pass != "onlytransfer") {
    _mostrarError(context, "Contrasenya incorrecta");
    return;
  }

  // Si la pass és OK (en qualsevol format de lletra), busquem la reserva
  var doc = await FirebaseFirestore.instance.collection('reserves').doc(codi).get();
  
  if (doc.exists) {
    if (!context.mounted) return;
    Navigator.pop(context);
  Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaClientWeb()));
  } else {
    _mostrarError(context, "Codi de reserva no trobat");
  }
},            child: const Text("ENTRAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    if (!_carregat) return const Scaffold(backgroundColor: Color(0xFF2D3142));
    double ample = MediaQuery.of(context).size.width;
    double alt = MediaQuery.of(context).size.height;

    return Scaffold(
      // 1. EL MENÚ LATERAL (DRAWER)
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
                    Navigator.pop(context); // Tanca el menú
                    _mostrarDialegCodi(context); // Mostra el quadre del codi
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
          // FONS D'IMATGE
          Image.asset('assets/fons_app.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.35)),

          // LOGOTIP CENTRAL
          Center(
            child: Image.asset(
              'assets/imatges/onlytransfer_logo.png',
              height: 130,
              fit: BoxFit.contain,
            ),
          ),

          // 2. LES TRES RATLLETES (A DALT A LA DRETA)
          Positioned(
            top: 50,
            right: 20,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 35),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ),

          // BOTÓ INFERIOR CLIENT
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
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Column(
                  children: [
                    Text(t('receptor_boto').toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                    const SizedBox(height: 10),
                    Text(t('receptor_lema'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ),
          ),

          // ZONA INVISIBLE CONDUCTOR (Doble Tap)
          Positioned(
            top: alt * 0.35,
            left: ample * 0.25,
            child: GestureDetector(
              onDoubleTap: () => _gestionarAccesConductor(),
              child: Container(width: 200, height: 200, color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
// Funció per mostrar missatges d'error de forma elegant (SnackBars)
  void _mostrarError(BuildContext context, String missatge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          missatge,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2D3142), // Gris fosc per seguir el teu estil
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
