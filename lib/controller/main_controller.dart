import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';

class MainController extends StatefulWidget {
  const MainController({super.key});

  @override
  State<MainController> createState() => _MainControllerState();
}

class _MainControllerState extends State<MainController> {
  int index = 0;

  final pages = const [
    DashboardPage(),
    SizedBox(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
        onTap: (i) {
          if (i == 1) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Log Keluar"),
                content: const Text("Adakah anda pasti ingin log keluar?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Log Keluar"),
                  )
                ],
              ),
            );
          } else {
            setState(() => index = i);
          }
        },
      ),
    );
  }
}
