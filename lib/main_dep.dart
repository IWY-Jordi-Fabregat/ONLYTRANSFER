import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'portada_vip_screen.dart'; // La pantalla amb la teva imatge i el logotip
import 'llista_reserves_screen.dart';
import 'resum_reserva_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Connectem amb Dubai (Firebase)
  runApp(const OnlyTransferApp());
}

class OnlyTransferApp extends StatelessWidget {
  const OnlyTransferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OnlyTransfer VIP',
      // DEFINIM ELS COLORS CORPORATIUS AQUÍ
      theme: ThemeData(
        primaryColor: const Color(0xFFFF700A), // Taronja
        scaffoldBackgroundColor: const Color(0xFF2D3142), // Gris Negre
        fontFamily: 'AppleColorEmoji', // O la font que t'agradi estil Apple
      ),
      // LA PÀGINA D'INICI ÉS LA TEVA PORTADA AMB LA IMATGE
      home: const PortadaVipScreen(), 
    );
  }
}
