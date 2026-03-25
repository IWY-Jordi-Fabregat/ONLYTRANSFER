import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'panell_conductor_screen.dart';

class LlistaReservesScreen extends StatelessWidget {
  const LlistaReservesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142),
      appBar: AppBar(
        title: const Text("RADAR DE RESERVES", 
          style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reserves')
            .where('estat', isNotEqualTo: 'FINALITZAT')
            .orderBy('estat')
            .orderBy('creat_el', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("ERROR DE CONEXIÓ: Cal crear l'índex.\n\n${snapshot.error}",
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF700A)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("RADAR NET", style: TextStyle(color: Colors.white70)));
          }

          var reserves = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reserves.length,
            itemBuilder: (context, index) {
              var dades = reserves[index].data() as Map<String, dynamic>;
              String client = dades['welcome_sign'] ?? "Sense nom";
              String vol = dades['vol_tren'] ?? "---";

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white10),
                ),
                child: ListTile(
                  title: Text(client, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("VOL: $vol", style: const TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 15),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PanellConductorScreen(
                          numeroVol: vol,
                          reservaId: reserves[index].id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
