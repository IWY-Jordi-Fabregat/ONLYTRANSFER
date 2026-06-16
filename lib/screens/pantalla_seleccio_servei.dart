import 'package:flutter/material.dart';
import '../main.dart';
import 'experiencia_client.dart';
import 'pantalla_reserva_corporativa.dart';

class PantallaSeleccioServei extends StatelessWidget {
  const PantallaSeleccioServei({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                t('app_titol'),
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 40),
              _botoServei(
                context,
                icon: Icons.flight_takeoff,
                title: t('menu_transfer'),
                subtitle: '',
                color: const Color(0xFFFF700A),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExperienciaClient(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              _botoServei(
                context,
                icon: Icons.access_time,
                title: t('menu_disposicio'),
                subtitle: '',
                color: const Color(0xFF778591),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('En preparació'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              _botoServei(
                context,
                icon: Icons.map,
                title: t('menu_vip'),
                subtitle: '',
                color: const Color(0xFF2D3142),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('En preparació'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              _botoServei(
                context,
                icon: Icons.business,
                title: t('menu_corporatiu'),
                subtitle: t('menu_corporatiu_sub'),
                color: Colors.black,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PantallaReservaCorporativa(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botoServei(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
