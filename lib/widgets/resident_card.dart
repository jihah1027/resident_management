import 'package:flutter/material.dart';

class ResidentCard extends StatelessWidget {
  final String name;
  final int age;
  final String phoneNumber;
  final String address;
  final String lastUpdate;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ResidentCard({
    super.key,
    required this.name,
    required this.age,
    required this.phoneNumber,
    required this.address,
    required this.lastUpdate,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Umur: $age"),
            Text("Telefon: $phoneNumber"),
            Text("Alamat: $address"),
            Text("Kemaskini: $lastUpdate"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
