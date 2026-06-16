import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConLlistatServeis extends StatelessWidget {
  final Function(String id, Map<String, dynamic> dades) onSeleccionarViatge;
  final Function(String id) onObrirXat;
  final VoidCallback onSortir;

  const ConLlistatServeis({
    super.key,
    required this.onSeleccionarViatge,
    required this.onObrirXat,
    required this.onSortir,
  });

  final Color taronja = const Color(0xFFFF700A);
  final Color grisNegre = const Color(0xFF2D3142);
  final Color grisClar = const Color(0xFFF0F2F5);

  @override
  Widget build(BuildContext context) {
    // Calculem els límits de temps: des d'ara mateix fins a final de demà
    DateTime ara = DateTime.now();
    DateTime finalDeDema = DateTime(ara.year, ara.month, ara.day + 2, 0, 0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(25),
          child: Text(
            "SERVEIS PROPERS (AVUI I DEMÀ)",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              letterSpacing: 2, 
              fontSize: 11, 
              color: taronja
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reserves')
                // Filtrem per estats operatius
                .where('estat_servei', whereIn: ['ASSIGNAT', 'EN CAMÍ', 'AL LLOC', 'AMB EL CLIENT', 'EN VIATGE'])
                .orderBy('data', descending: false)
                .orderBy('hora', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              // Filtrem manualment per data per no complicar els índexs de Firebase
              var reserves = snapshot.data!.docs.where((doc) {
                DateTime dataDoc = DateTime.parse(doc['data']);
                return dataDoc.isBefore(finalDeDema);
              }).toList();

              if (reserves.isEmpty) {
                return const Center(child: Text("No hi ha serveis per avui ni demà."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: reserves.length,
                itemBuilder: (context, index) {
                  var doc = reserves[index];
                  var res = doc.data() as Map<String, dynamic>;
                  
                  // LOGICA DE COLORS I URGÈNCIA
                  DateTime dataServei = DateTime.parse(res['data']);
                  if (res['hora'] != null) {
                    List<String> h = res['hora'].split(':');
                    dataServei = DateTime(dataServei.year, dataServei.month, dataServei.day, int.parse(h[0]), int.parse(h[1]));
                  }
                  
                  Duration dif = dataServei.difference(ara);
                  
                  Color colorFons = Colors.white;
                  Color colorBorda = Colors.grey.shade200;
                  
                  if (dif.inHours > 24) {
                    colorFons = const Color(0xFFF2F4F6); // Gris: Més de 24h (Demà)
                    colorBorda = Colors.transparent;
                  } else if (dif.inHours < 12 && dif.inHours >= 0) {
                    colorFons = taronja.withOpacity(0.1); // Taronja: Urgència (<12h)
                    colorBorda = taronja.withOpacity(0.3);
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: colorFons,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: colorBorda)
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      onTap: () => onSeleccionarViatge(doc.id, res),
                      title: Text(
                        (res['client'] ?? 'CLIENT VIP').toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 14, 
                          color: grisNegre, 
                          letterSpacing: 1.2, 
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "${res['hora'] ?? '--:--'} H - ${res['origen'] ?? '-'}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1),
                          ),
                          if (dif.inHours < 12 && dif.inHours >= 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "RECOLLIDA EN ${dif.inHours}H ${dif.inMinutes % 60}MIN",
                                style: TextStyle(color: taronja, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.chat_bubble_outline, color: taronja),
                        onPressed: () => onObrirXat(doc.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // BOTÓ SORTIDA
        Padding(
          padding: const EdgeInsets.all(25),
          child: GestureDetector(
            onTap: onSortir,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: grisNegre, borderRadius: BorderRadius.circular(15)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.power_settings_new, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text("TANCAR SESSIÓ CONDUCTOR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
