import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendaClientsScreen extends StatelessWidget {
  const AgendaClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3142), // Gris Negre
      appBar: AppBar(
        title: const Text("AGENDA CORPORATIVA", 
          style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business, color: Color(0xFFFF700A)),
            onPressed: () => _mostrarDialegAfegir(context),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clients_corporatius').orderBy('nom').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var empreses = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: empreses.length,
            itemBuilder: (context, index) {
              var dades = empreses[index].data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: const Icon(Icons.business, color: Color(0xFF778591)),
                  title: Text(dades['nom'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("CIF: ${dades['cif']}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                  onTap: () {
                    // Aquí podríem editar o veure més detalls
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Funció per afegir una empresa nova sense complicacions
  void _mostrarDialegAfegir(BuildContext context) {
    final nomController = TextEditingController();
    final cifController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3142),
        title: const Text("NOVA EMPRESA", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _campPetit("NOM EMPRESA", nomController),
            _campPetit("CIF", cifController),
            _campPetit("EMAIL FACTURACIÓ", emailController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL·LAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF700A)),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('clients_corporatius').add({
                'nom': nomController.text,
                'cif': cifController.text,
                'email': emailController.text,
                'creat_el': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  Widget _campPetit(String etiqueta, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: Color(0xFF778591), fontSize: 10),
      ),
    );
  }
}
