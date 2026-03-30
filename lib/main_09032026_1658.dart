import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSy...", 
        appId: "1:...", 
        messagingSenderId: "...", 
        projectId: "only-transfer-vip"
      ),
    );
  } catch (e) {
    debugPrint("Firebase en espera");
  }
  runApp(const OnlyTransferApp());
}

class OnlyTransferApp extends StatelessWidget {
  const OnlyTransferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFF700A),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        fontFamily: 'SF Pro Display',
      ),
      home: const PantallaLoginUnica(),
    );
  }
}

// --- PANTALLA D'ENTRADA ---
class PantallaLoginUnica extends StatefulWidget {
  const PantallaLoginUnica({super.key});

  @override
  State<PantallaLoginUnica> createState() => _PantallaLoginUnicaState();
}

class _PantallaLoginUnicaState extends State<PantallaLoginUnica> {
  final TextEditingController _codiController = TextEditingController();

  void _validarEntrada() {
    String codi = _codiController.text;
    if (codi == '1234') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardOnlyTransfer(isAdmin: true)));
    } else if (codi == '8888') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardOnlyTransfer(isAdmin: false)));
    } else if (codi == '5555') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VistaConductor()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Codi incorrecte')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_car, size: 60, color: Color(0xFFFF700A)),
              const SizedBox(height: 40),
              TextField(
                controller: _codiController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: 'CODI D\'ACCÉS', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validarEntrada,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF700A), minimumSize: const Size(double.infinity, 55)),
                child: const Text('ENTRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DASHBOARD DUAL ---
class DashboardOnlyTransfer extends StatefulWidget {
  final bool isAdmin;
  const DashboardOnlyTransfer({super.key, required this.isAdmin});

  @override
  State<DashboardOnlyTransfer> createState() => _DashboardOnlyTransferState();
}

class _DashboardOnlyTransferState extends State<DashboardOnlyTransfer> {
  final TextEditingController _cercaController = TextEditingController();

  void _afegirNota(String client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nota per a $client", style: const TextStyle(fontSize: 16)),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: "Escriu instruccions per al xofer o l'empresa...", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL·LAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF700A)),
            onPressed: () => Navigator.pop(context), 
            child: const Text("GUARDAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('ONLYTRANSFER', style: TextStyle(color: Color(0xFF2D3142), fontSize: 12, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // BARRA DE CERCA RÀPIDA
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _cercaController,
              decoration: InputDecoration(
                hintText: "Busca un client o viatge...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF700A)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                if (widget.isAdmin) ...[
                  Row(
                    children: [
                      _targetaKPI("AVUI", "240€", const Color(0xFFFF700A)),
                      const SizedBox(width: 10),
                      _targetaKPI("MES", "4.200€", const Color(0xFF2D3142)),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
                _itemLlistaViatge("Jordi Fabregat", "BCN", "MAD", 120.0, "VIP-FRIEND", widget.isAdmin),
                _itemLlistaViatge("Emma R.", "BCN", "AND", 180.0, "", widget.isAdmin),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _targetaKPI(String titol, String valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titol, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(valor, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _itemLlistaViatge(String client, String ori, String dest, double preu, String promo, bool admin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(client, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Row(children: [
                  Text(ori, style: const TextStyle(color: Color(0xFFFF700A), fontWeight: FontWeight.bold)),
                  const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
                  Text(dest, style: const TextStyle(color: Color(0xFF2D3142), fontWeight: FontWeight.bold)),
                ]),
              ]),
              if (admin)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text("+${(preu * 0.2).toStringAsFixed(2)}€", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF700A))),
                  IconButton(
                    icon: const Icon(Icons.note_add_outlined, size: 20, color: Colors.grey),
                    onPressed: () => _afegirNota(client),
                  )
                ])
              else
                Text("${(preu * 0.8).toStringAsFixed(0)}€", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- VISTA CONDUCTOR ---
class VistaConductor extends StatelessWidget {
  const VistaConductor({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      body: const Center(child: Text("Pantalla de treball del xofer.", style: TextStyle(color: Colors.white))),
    );
  }
}
