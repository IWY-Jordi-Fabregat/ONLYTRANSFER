import 'package:flutter/material.dart';
import 'geocoding_helper.dart';
import 'resum_caixa_final.dart';

class PanellConductorScreen extends StatefulWidget {
  final String numeroVol;
  final String reservaId;
	const PanellConductorScreen({
    	super.key, 
    	required this.numeroVol, 
    	required this.reservaId, // Afegim això aquí dins
 	 });
  
  @override
  State<PanellConductorScreen> createState() => _PanellConductorScreenState();
}

class _PanellConductorScreenState extends State<PanellConductorScreen> {
  late Map<String, String> infoVol;
  
  // AQUESTA VARIABLE CONTROLA EL SEGUIMENT (1 a 5)
  int pasActual = 1; 

  @override
  void initState() {
    super.initState();
    infoVol = GeocodingHelper.verificarTerminal(widget.numeroVol);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF778591)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("SERVEI EN CURS", style: TextStyle(letterSpacing: 2, fontSize: 12, color: Color(0xFF778591))),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            _targetaInformativa(),
            const Spacer(),
            
            // EL TEU NOU BOTÓ DE SEGUIMENT INTEL·LIGENT
            _botoSeguimentDinamnic(),
          ],
        ),
      ),
    );
  }

 Widget _botoSeguimentDinamnic() {
    String textBoto = "";
    
    if (pasActual == 1) textBoto = "SORTIDA DE BASE";
    if (pasActual == 2) textBoto = "ARRIBADA AL PUNT";
    if (pasActual == 3) textBoto = "CLIENT A BORD";
    if (pasActual == 4) textBoto = "CLIENT AL SEU DESTÍ";
    if (pasActual == 5) textBoto = "FINALITZAR I FACTURAR";

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF700A), // El teu taronja OnlyTransfer
        // AQUÍ HEM DUPLICAT L'ALÇADA (de 60 a 120)
        minimumSize: const Size(double.infinity, 120), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8, // Una mica d'ombra perquè sembli que "flota"
      ),
      onPressed: () {
        setState(() {
          if (pasActual < 5) {
            pasActual++;
          } else {
          // CANVIA AIXÒ:
Navigator.push(context, MaterialPageRoute(builder: (context) => ResumCaixaFinal(reservaId: widget.reservaId)));
          }
        });
      },
      child: Text(
        textBoto, 
        textAlign: TextAlign.center, // Per si el text és llarg
        style: const TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold, 
          fontSize: 22, // També fem la lletra una mica més gran
          letterSpacing: 2
        ),
      ),
    );
  }
  // ... (aquí sota mantens els teus mètodes _targetaInformativa i _filaDada igual que els tenies)
  Widget _targetaInformativa() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF700A), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.numeroVol, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const Icon(Icons.flight_land, color: Color(0xFFFF700A), size: 30),
            ],
          ),
          const Divider(color: Colors.white10, height: 40),
          _filaDada("DESTÍ:", infoVol['terminal']!),
          const SizedBox(height: 10),
          _filaDada("PUNT DE TROBADA:", infoVol['instruccions']!),
          const SizedBox(height: 10),
          _filaDada("ESTAT REAL:", "ATERRA A LES 14:20 (ESTIMAT)"),
        ],
      ),
    );
  }

  Widget _filaDada(String etiqueta, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(color: Color(0xFF778591), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Expanded(child: Text(valor, style: const TextStyle(color: Colors.white, fontSize: 14))),
      ],
    );
  }
}
