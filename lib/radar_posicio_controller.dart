import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RadarPosicio extends StatefulWidget {
  @override
  _RadarPosicioState createState() => _RadarPosicioState();
}

class _RadarPosicioState extends State<RadarPosicio> {
  // Posició inicial: Aeroport de Barcelona (T1)
  static const CameraPosition _posicioInicial = CameraPosition(
    target: LatLng(41.2889, 2.0711),
    zoom: 14.0,
  );

  // Marcadors dels punts clau de la teva feina
  final Set<Marker> _puntsDePau = {
    Marker(
      markerId: MarkerId('T1'),
      position: LatLng(41.2889, 2.0711),
      infoWindow: InfoWindow(title: 'TERMINAL T1', snippet: 'Punt de Recollida VIP'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ),
    Marker(
      markerId: MarkerId('T2'),
      position: LatLng(41.3032, 2.0744),
      infoWindow: InfoWindow(title: 'TERMINAL T2', snippet: 'Clients Corporatius'),
    ),
    Marker(
      markerId: MarkerId('Privats'),
      position: LatLng(41.2950, 2.0650),
      infoWindow: InfoWindow(title: 'VOLS PRIVATS', snippet: 'Clients Nivell Somb'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142),
      appBar: AppBar(
        title: Text("RADAR DE POSICIÓ - BARCELONA", style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // EL MAPA REAL
          GoogleMap(
            initialCameraPosition: _posicioInicial,
            markers: _puntsDePau,
            myLocationEnabled: true,
            mapType: MapType.normal,
          ),
          
          // CAPA SUPERIOR (Overlay) AMB INFORMACIÓ
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2D3142).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFFF700A), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("ESTAT DEL TRÀNSIT", style: TextStyle(color: Colors.white38, fontSize: 12)),
                      Text("FLUID CAP A LA T1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Icon(Icons.speed, color: Color(0xFFFF700A), size: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
