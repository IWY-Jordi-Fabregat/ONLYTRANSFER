import 'package:flutter/material.dart';

class WebOperadorScreen extends StatelessWidget {
  const WebOperadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            // El teu logo de OnlyTransfer
            Image.asset('assets/logo_app.png', height: 40),
            const SizedBox(width: 20),
            const Text("PANEL DE GESTIÓN LOGÍSTICA", 
              style: TextStyle(color: Color(0xFF2D3142), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ],
        ),
        actions: [
          const Center(
            child: Text("OPERADOR: MADRID CENTRAL  ", 
              style: TextStyle(color: Color(0xFF778591), fontSize: 12, fontWeight: FontWeight.w500))
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("SERVICIOS ASIGNADOS HOY", 
                  style: TextStyle(color: Color(0xFFFF700A), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                Text("Domingo, 29 de Marzo", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            
            // TABLA DE GESTIÓN PROFESIONAL
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF1F1F1)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ListView(
                    children: [
                      _buildHeaderTable(),
                      const Divider(height: 1),
                      _buildFilaServicio("09:00", "SR. RODRÍGUEZ", "HOTEL RITZ -> AEROPUERTO T4", "CLASE S", "CONFIRMADO"),
                      _buildFilaServicio("12:30", "SRA. GARCÍA", "ATOCHA -> BARRIO DE SALAMANCA", "V-CLASS", "PENDIENTE"),
                      _buildFilaServicio("16:00", "CORP. DUBAI", "IFEMA -> REST. AMAZÓNICO", "MINIBUS VIP", "EN RUTA"),
                      _buildFilaServicio("21:00", "SR. CHEN", "SANTIAGO BERNABÉU -> HOTEL VILLAMAGNA", "CLASE S", "PENDIENTE"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFF8F9FA),
      child: Row(
        children: const [
          Expanded(flex: 1, child: Text("HORA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF556677)))),
          Expanded(flex: 2, child: Text("CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF556677)))),
          Expanded(flex: 4, child: Text("TRAYECTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF556677)))),
          Expanded(flex: 2, child: Text("VEHÍCULO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF556677)))),
          Expanded(flex: 1, child: Text("ESTADO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF556677)))),
        ],
      ),
    );
  }

  Widget _buildFilaServicio(String hora, String cliente, String trayecto, String vehiculo, String estado) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1))),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          Expanded(flex: 2, child: Text(cliente, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(flex: 4, child: Text(trayecto, style: const TextStyle(color: Color(0xFF778591)))),
          Expanded(flex: 2, child: Text(vehiculo)),
          Expanded(flex: 1, child: _badgeEstado(estado)),
        ],
      ),
    );
  }

  Widget _badgeEstado(String estado) {
    Color color = const Color(0xFF778591);
    if (estado == "PENDIENTE") color = const Color(0xFFFF700A);
    if (estado == "EN RUTA") color = Colors.blueGrey;
    if (estado == "CONFIRMADO") color = const Color(0xFF556677);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(estado, textAlign: TextAlign.center, 
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
