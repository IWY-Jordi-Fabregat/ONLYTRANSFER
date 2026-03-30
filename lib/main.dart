import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const OnlyTransferApp());
}

// --- CONFIGURACIÓ DE PREUS (L'estanteria de Jordi) ---
const Map<String, double> PREUS_ESTANDARD = {
  "Aeroport BCN": 75.0,
  "Estació de Sants": 45.0,
  "Port de Barcelona": 55.0,
  "Montserrat (Mig dia)": 250.0,
  "Caves Codorniu": 300.0,
};

class OnlyTransferApp extends StatelessWidget {
  const OnlyTransferApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'SF Pro Display',
      ),
      home: const PantallaSeleccio(),
    );
  }
}

// --- 1. SELECCIÓ (Missatges suaus i estètica Apple) ---
class PantallaSeleccio extends StatelessWidget {
  const PantallaSeleccio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ONLYTRANSFER", 
          style: TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        children: [
          const Icon(Icons.directions_car_filled, color: Color(0xFFFF700A), size: 45),
          const SizedBox(height: 25),
          const Text("Benvingut a OnlyTransfer,", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Text("Tenim per a tu tres tipus de servei,", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const Text("Tria el servei que necessitis,", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
          
          const SizedBox(height: 40),

          _seccioMenu(context, "TRASLLAT", Icons.airplanemode_active, 
            "El servei de trasllat per exemple del Aeroport a Barcelona o de Barcelona al Aeroport és el més habitual."),

          _seccioMenu(context, "DISPOSICIÓ", Icons.access_time, 
            "El servei de disposició està pensat per fer tours turístics per la ciutat i per fora com Montserrat o les Caves Codorniu."),

          _seccioMenu(context, "ESDEVENIMENTS", Icons.celebration, 
            "Pensat per atendre Congressos, Events esportius o Concerts amb un temps determinat."),
        ],
      ),
    );
  }

  Widget _seccioMenu(BuildContext ctx, String t, IconData i, String desc) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (ctx) => PantallaDades(tipus: t))),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(children: [
            Icon(i, color: const Color(0xFFFF700A), size: 26),
            const SizedBox(width: 20),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3142))),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF778591)),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 25, left: 10),
        child: Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
      ),
    ],
  );
}

// --- 2. DADES I RUTES RÀPIDES ---
class PantallaDades extends StatefulWidget {
  final String tipus;
  const PantallaDades({super.key, required this.tipus});
  @override
  State<PantallaDades> createState() => _PantallaDadesState();
}

class _PantallaDadesState extends State<PantallaDades> {
  final cOrig = TextEditingController();
  final cDest = TextEditingController();
  final cPreu = TextEditingController();
  final cSign = TextEditingController();

  void aplicarPreu(String desti, double preu) {
    setState(() {
      cOrig.text = "Barcelona Centre";
      cDest.text = desti;
      cPreu.text = preu.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tipus), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("RUTES RÀPIDES", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF700A))),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            if(widget.tipus == "TRASLLAT") ...[
              ActionChip(label: const Text("Aeroport"), onPressed: () => aplicarPreu("Aeroport BCN", PREUS_ESTANDARD["Aeroport BCN"]!)),
              ActionChip(label: const Text("Sants"), onPressed: () => aplicarPreu("Estació de Sants", PREUS_ESTANDARD["Estació de Sants"]!)),
            ],
            if(widget.tipus == "DISPOSICIÓ") ...[
              ActionChip(label: const Text("Montserrat"), onPressed: () => aplicarPreu("Montserrat", PREUS_ESTANDARD["Montserrat (Mig dia)"]!)),
              ActionChip(label: const Text("Caves"), onPressed: () => aplicarPreu("Caves Codorniu", PREUS_ESTANDARD["Caves Codorniu"]!)),
            ],
          ]),
          const SizedBox(height: 30),
          _camp(cOrig, "PUNT DE RECOLLIDA", Icons.location_on),
          _camp(cDest, "DESTÍ", Icons.flag),
          _camp(cSign, "WELCOME SIGN", Icons.badge),
          _camp(cPreu, "PREU (€)", Icons.euro_symbol, teclatNumeric: true),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaFactura(resum: {
              'T': widget.tipus, 'O': cOrig.text, 'D': cDest.text, 'PREU': cPreu.text, 'SIGN': cSign.text
            }))),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF700A), minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("CONTINUAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  Widget _camp(TextEditingController c, String l, IconData i, {bool teclatNumeric = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextField(
      controller: c, keyboardType: teclatNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: l, prefixIcon: Icon(i, color: const Color(0xFFFF700A)))
    ),
  );
}

// --- 4. FACTURACIÓ I FIREBASE ---
class PantallaFactura extends StatelessWidget {
  final Map<String, String> resum;
  PantallaFactura({super.key, required this.resum});

  final cNom = TextEditingController();
  final cTax = TextEditingController();
  final cMail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FACTURACIÓ"), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(children: [
          _i("NOM O EMPRESA", cNom),
          _i("TAX ID / DNI / CIF", cTax),
          _i("EMAIL", cMail),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              Map<String, String> totPlegat = {
                ...resum, 
                'CLIENT': cNom.text, 
                'TAX_ID': cTax.text, 
                'MAIL': cMail.text,
                'DATA': DateTime.now().toString()
              };
              
              await FirebaseFirestore.instance.collection('viatges').add(totPlegat);

              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaAgraiment(dades: totPlegat)));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF700A), minimumSize: const Size(double.infinity, 70), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35))),
            child: const Text("CONFIRMAR RESERVA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }
  Widget _i(String l, TextEditingController c) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextField(controller: c, decoration: InputDecoration(labelText: l)),
  );
}

// --- 5. AGRAÏMENT (Estil Global) ---
class PantallaAgraiment extends StatelessWidget {
  final Map<String, String> dades;
  const PantallaAgraiment({super.key, required this.dades});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFFF700A), size: 100),
              const SizedBox(height: 30),
              const Text(
                "RESERVA REGISTRADA", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2D3142))
              ),
              const SizedBox(height: 15),
              const Text(
                "Reserva grabada a nuestros servidores centrales en todo el mundo.", 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15, height: 1.5)
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D3142), // Gris Negre per a un acabat elegant
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ), 
                child: const Text("TORNAR A L'INICI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
