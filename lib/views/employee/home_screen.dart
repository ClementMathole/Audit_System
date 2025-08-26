import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skills_audit_system/views/employee/employee_dashboard.dart';
import 'qualifications/qualifications_screen.dart';
import 'skills/skills_screen.dart';
import 'trainings/trainings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    EmployeeDashboard(),
    QualificationsScreen(),
    SkillsScreen(),
    TrainingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: "Qualifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star),
            label: "Skills",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: "Training",
          ),
        ],
      ),
    );
  }
}
