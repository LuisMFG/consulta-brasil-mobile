import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'gastos_screen.dart';
import 'security_screen.dart';
import 'configuracoes_screen.dart';
import 'avaliacao_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GastosScreen(),
    const SegurancaScreen(),
    const ConfiguracoesScreen(),
    const AvaliacaoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Gastos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Seguranca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Config',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Avaliar',
          ),
        ],
      ),
    );
  }
}