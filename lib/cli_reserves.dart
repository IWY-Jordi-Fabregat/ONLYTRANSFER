import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- ELS TEUS MÒDULS METÒDICS ---
import 'widgets/wid_xat_servei.dart';
import 'cli_resum_viatge.dart';
import 'cli_nova_reserva.dart';
import 'con_llistat_serveis.dart';
import 'con_control_viatge.dart';
import 'cli_benvinguda.dart'; 

// --- COLORS CORPORATIUS ONLYTRANSFER ---
const Color colorFonsBlanc = Colors.white;
const Color colorTaronjaVIP = Color(0xFFFF700A);
const Color colorGrisClarBackground = Color(0xFFF0F2F5);
const Color colorGrisNegre = Color(0xFF2D3142);

class ExperienciaClient extends StatefulWidget {
  final int pasInicial; // Permet entrar directament a un mòdul (ex: conductors)
  const ExperienciaClient({super.key, this.pasInicial = 0});

  @override
  State<ExperienciaClient> createState() => _ExperienciaClientState();
}

class _ExperienciaClientState extends State<ExperienciaClient> {
  late int _pasActual; // Fem que sigui 'late' per carregar el pasInicial
  bool _processant = false;
  Map<String, dynamic>? _reservaConsultada;
  String? _reservaSeleccionadaId; 
  String _nomXoferTrobat = "Assignant xofer..."; 
  
  final TextEditingController _cercaCodiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Quan l'app s'obre, mirem si venim de la benvinguda amb un pas específic
    _pasActual = widget.pasInicial;
  }

  void _anarAConductors() { setState(() => _pasActual = 7); }

  Future<void> _buscarReserva([String? codiDirecte]) async {
    String codi = codiDirecte ?? _cercaCodiController.text.trim().toUpperCase();
    if (codi.isEmpty) return;
    setState(() => _processant = true);
    try {
      final query = await FirebaseFirestore.instance.collection('reserves').where('codi_reserva', isEqualTo: codi).limit(1).get();
      if (query.docs.isNotEmpty) {
        var dades = query.docs.first.data();
        String? uidXofer = dades['UID_xofer'];

        if (uidXofer != null && uidXofer.isNotEmpty) {
          final xoferDoc = await FirebaseFirestore.instance.collection('xofers').doc(uidXofer).get();
          if (xoferDoc.exists) {
            _nomXoferTrobat = xoferDoc.data()?['nom'] ?? "Xofer assignat";
          }
        } else {
          _nomXoferTrobat = "Pendent d'assignar";
        }

        setState(() {
          _reservaSeleccionadaId = query.docs.first.id;
          _reservaConsultada = dades;
          _pasActual = 6; 
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Codi no trobat."), backgroundColor: Colors.red));
      }
    } finally { setState(() => _processant = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFonsBlanc,
      appBar: AppBar(
        flexibleSpace: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _anarAConductors,
          child: Container(color: Colors.transparent),
        ),
        title: const Column(mainAxisSize: MainAxisSize.min, children: [
          Text('ONLY TRANSFER', style: TextStyle(color: colorGrisNegre, letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
          Text('LUXURY TRANSPORT', style: TextStyle(fontSize: 8, color: colorTaronjaVIP, letterSpacing: 1)),
        ]),
        backgroundColor: colorFonsBlanc, elevation: 0, centerTitle: true,
        leading: _pasActual > 0 ? IconButton(icon: const Icon(Icons.arrow_back_ios, size: 18, color: colorGrisNegre), onPressed: () => setState(() => _pasActual = 0)) : null,
      ),
      body: _construirCos(),
    );
  }

  Widget _construirCos() {
    switch (_pasActual) {
      case 0: return _pantallaSeleccio();
      case 1: return CliNovaReserva(
          onReservaCompletada: (codi) => _buscarReserva(codi),
          onCancel: () => setState(() => _pasActual = 0),
        );
      case 5: return _pantallaCercaCodi();
      case 6: return CliResumViatge(
          dades: _reservaConsultada!,
          nomXofer: _nomXoferTrobat,
          onModificarHora: () async {
            TimeOfDay? nova = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (nova != null) {
              await FirebaseFirestore.instance.collection('reserves').doc(_reservaSeleccionadaId!).update({'hora': nova.format(context)});
              _buscarReserva();
            }
          },
          onObrirXat: () => setState(() => _pasActual = 9),
          onTornar: () => setState(() => _pasActual = 0),
        );
case 7: // MÒDUL: LLISTAT CONDUCTOR (con_llistat_serveis.dart)
        return ConLlistatServeis(
          onSeleccionarViatge: (id, dades) => setState(() {
            _reservaSeleccionadaId = id;
            _reservaConsultada = dades;
            _pasActual = 8;
          }),
          // Connectem el xat des del llistat
          onObrirXat: (id) => setState(() {
            _reservaSeleccionadaId = id;
            _pasActual = 9;
          }),
          onSortir: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const CliBenvinguda()),
              (Route<dynamic> route) => false,
            );
          },
        );

case 8: // MÒDUL: CONTROL CONDUCTOR (con_control_viatge.dart)
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('reserves').doc(_reservaSeleccionadaId!).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            return ConControlViatge(
              reservaId: _reservaSeleccionadaId!,
              dades: snapshot.data!.data() as Map<String, dynamic>,
              onFinalitzat: () {
                // Si el servei s'ha acabat de veritat, sí que tornem al logo per seguretat
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const CliBenvinguda()),
                  (Route<dynamic> route) => false,
                );
              },
              // CANVI CLAU AQUÍ: 
              // En lloc de tancar l'app, només tornem al pas 7 (el llistat de viatges)
              onTornar: () => setState(() => _pasActual = 7), 
              
              onObrirXat: () => setState(() => _pasActual = 9),
            );
          }
        );

      case 9: return WidXatServei(
          reservaId: _reservaSeleccionadaId!,
          titolXat: _nomXoferTrobat,
        );
      default: return _pantallaSeleccio();
    }
  }

  // --- PANTALLES BÀSIQUES ---
  Widget _pantallaSeleccio() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.airplanemode_active, color: colorTaronjaVIP, size: 40),
      const SizedBox(height: 60),
      _botoAccio("NOVA RESERVA", () => setState(() => _pasActual = 1)),
      const SizedBox(height: 15),
      _botoGris("CONSULTAR RESERVA", () => setState(() => _pasActual = 5)),
      const SizedBox(height: 40), 
      _botoGris("SORTIR A L'INICI", () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CliBenvinguda()),
          (Route<dynamic> route) => false,
        );
      }),
    ]));
  }

  Widget _pantallaCercaCodi() {
    return Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("ENTRA EL TEU CODI", style: TextStyle(color: colorTaronjaVIP, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      TextField(controller: _cercaCodiController, decoration: InputDecoration(filled: true, fillColor: colorGrisClarBackground, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      const SizedBox(height: 30),
      _processant ? const CircularProgressIndicator() : _botoAccio("BUSCAR", () => _buscarReserva()),
    ]));
  }

  // --- WIDGETS DE BOTONS ---
  Widget _botoAccio(String text, VoidCallback onTap) {
    return SizedBox(width: 250, height: 50, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: colorTaronjaVIP, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Widget _botoGris(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        width: 250, 
        padding: const EdgeInsets.all(15), 
        decoration: BoxDecoration(
          color: colorGrisClarBackground, 
          borderRadius: BorderRadius.circular(12)
        ), 
        child: Center(
          child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF556677)))
        )
      )
    );
  }
}
