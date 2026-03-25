import 'package:flutter/material.dart';

class DashboardDubai extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2D3142), // Gris Negre
      appBar: AppBar(
        title: Text("ESTAT DE COMPTES - DUBAI", style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        actions: [Icon(Icons.account_balance_wallet, color: Color(0xFFFF700A)), SizedBox(width: 20)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("TOTAL ACUMULAT MES MARÇ", style: TextStyle(color: Colors.white38, fontSize: 14)),
            SizedBox(height: 10),
            Text("12.450,00 €", 
              style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            
            SizedBox(height: 40),
            
            // TARGETA DE FACTURES PENDENTS (Empreses)
            _targetaResum("TRANSFERÈNCIES PENDENTS", "3.200 €", Icons.history, Colors.blueAccent),
            SizedBox(height: 15),
            
            // TARGETA DE STRIPE (Ja cobrat)
            _targetaResum("COBRAT VIA STRIPE", "9.250 €", Icons.flash_on, Color(0xFFFF700A)),
            
            Spacer(),
            
            // GRÀFICA DE PROGRESSIÓ (Simbolitzada)
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text("RUMB A L'OBJECTIU: 83% COMPLETAT", 
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ),
            
            SizedBox(height: 30),
            Center(child: Text("CONTROL DE TEMPS = LLIBERTAT", 
              style: TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.5))),
          ],
        ),
      ),
    );
  }

  Widget _targetaResum(String titol, String import, IconData icona, Color colorIcona) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icona, color: colorIcona, size: 30),
              SizedBox(width: 15),
              Text(titol, style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          Text(import, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
