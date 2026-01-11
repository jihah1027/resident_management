import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resident_model.dart';
import 'add_resident_page.dart';

class ResidentDetailsPage extends StatefulWidget {
  final Resident residentData;

  const ResidentDetailsPage({super.key, required this.residentData});

  @override
  State<ResidentDetailsPage> createState() => _ResidentDetailsPageState();
}

class _ResidentDetailsPageState extends State<ResidentDetailsPage> {
  late Resident currentResident;

  @override
  void initState() {
    super.initState();
    currentResident = widget.residentData;
  }

  /// Generates a PDF of the specific resident details
  Future<void> _exportResidentToPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Profil Penduduk: ${currentResident.name}",
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Text("Maklumat Ketua Isi Rumah (KIR)",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Bullet(text: "Nama: ${currentResident.name}"),
          pw.Bullet(text: "Umur: ${currentResident.age}"),
          pw.Bullet(text: "Telefon: ${currentResident.phone}"),
          pw.Bullet(text: "Alamat: ${currentResident.address}"),
          pw.Bullet(text: "Mukim/Kampung: ${currentResident.mukim} / ${currentResident.kampung}"),
          pw.Bullet(text: "Pendapatan: ${currentResident.incomeRange}"),
          pw.Bullet(text: "Bantuan: ${currentResident.bantuan?.join(', ') ?? '-'}"),
          pw.SizedBox(height: 30),
          pw.Text("Senarai Ahli Isi Rumah",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
          pw.SizedBox(height: 10),
          if (currentResident.householdMembers.isEmpty)
            pw.Text("Tiada ahli isi rumah didaftarkan.")
          else
            pw.TableHelper.fromTextArray(
              headers: ['Nama', 'Hubungan', 'Umur', 'Status'],
              data: currentResident.householdMembers
                  .map((m) => [m.name, m.relation, m.age, m.status])
                  .toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            ),
          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text("Dikemaskini pada: ${currentResident.lastUpdate}"),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Profil_${currentResident.name.replaceAll(' ', '_')}.pdf',
    );
  }

  Widget _infoRow(String label, String? value) {
    final displayValue = (value == null || value.trim().isEmpty) ? "-" : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Text(": "),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bantuanList = currentResident.bantuan ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Butiran Penduduk"),
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Changed to return true for list refresh
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Passing the full currentResident object for editing
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddResidentPage(existingResident: currentResident),
                ),
              );

              // If the update was successful, refresh this local UI or go back
              if (result == true) {
                // Since data changed on server, usually we pop back to dashboard 
                // to let the dashboard reload the fresh data from your PHP API
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maklumat Ketua Isi Rumah (KIR)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.grey),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Nama", currentResident.name),
                    _infoRow("Umur", currentResident.age.toString()),
                    _infoRow("No Telefon", currentResident.phone),
                    _infoRow("Alamat", currentResident.address),
                    _infoRow("Mukim", currentResident.mukim),
                    _infoRow("Kampung", currentResident.kampung),
                    _infoRow("Pendapatan", currentResident.incomeRange),
                    _infoRow(
                      "Bantuan",
                      bantuanList.isEmpty ? "-" : bantuanList.join(", "),
                    ),
                    _infoRow("Tarikh Kemaskini", currentResident.lastUpdate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Ahli Isi Rumah",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            currentResident.householdMembers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Tiada ahli isi rumah"),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text("Nama", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Hubungan", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Umur", style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: currentResident.householdMembers.map((m) {
                          return DataRow(cells: [
                            DataCell(Text(m.name)),
                            DataCell(Text(m.relation)),
                            DataCell(Text(m.age)),
                            DataCell(Text(m.status)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Export Profil Ke PDF"),
                onPressed: _exportResidentToPdf,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}