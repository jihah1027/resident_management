import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/resident_model.dart';
import '../myconfig.dart';
import 'add_resident_page.dart';
import 'resident_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Resident> residentList = [];
  List<Resident> filteredList = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  /// Fetches the list of residents from the PHP backend
  Future<void> _loadResidents() async {
    setState(() => isLoading = true);
    try {
      // Ensure the filename load_residents.php matches your server file
      final response = await http.get(
        Uri.parse("${MyConfig.myurl}dataresidents/load_residents.php"),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          var list = data['data'] as List;
          setState(() {
            residentList = list.map((json) => Resident.fromJson(json)).toList();
            filteredList = residentList;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading residents: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Filters the list based on search input
  void _filterResidents(String query) {
    setState(() {
      searchQuery = query;
      filteredList = residentList.where((resident) {
        final nameMatch = resident.name.toLowerCase().contains(query.toLowerCase());
        final phoneMatch = resident.phone.contains(query);
        final mukimMatch = (resident.mukim ?? "").toLowerCase().contains(query.toLowerCase());
        return nameMatch || phoneMatch || mukimMatch;
      }).toList();
    });
  }

  /// Navigate to Add Page and refresh if data was saved
  void _goToAddResident() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddResidentPage()),
    );

    if (result == true) {
      _loadResidents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Penduduk"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResidents,
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterResidents,
              decoration: InputDecoration(
                hintText: "Cari nama, telefon, atau mukim...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadResidents,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final resident = filteredList[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueGrey,
                                  child: Text(
                                    resident.name.isNotEmpty ? resident.name[0].toUpperCase() : "?",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  resident.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "KIR • ${resident.mukim ?? 'N/A'} • ${resident.phone}",
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResidentDetailsPage(
                                        residentData: resident,
                                      ),
                                    ),
                                  );
                                  _loadResidents(); // Refresh when coming back
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddResident,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty 
                ? "Tiada data penduduk ditemui" 
                : "Tiada hasil untuk '$searchQuery'",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          if (searchQuery.isEmpty)
            ElevatedButton(
              onPressed: _goToAddResident,
              child: const Text("Tambah Sekarang"),
            )
        ],
      ),
    );
  }
}